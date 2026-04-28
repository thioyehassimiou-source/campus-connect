# Supabase RLS (Row Level Security) – Guide CampusConnect

Ce document explique comment sécuriser les données de CampusConnect avec **Row Level Security (RLS)** de Supabase, adapté à un projet universitaire.

---

## 1️⃣ Qu’est-ce que RLS ?

RLS = “Row Level Security”.  
C’est un mécanisme de **PostgreSQL** qui permet de définir des **règles** (policies) pour **qui peut lire / insérer / modifier / supprimer** chaque ligne d’une table.

> **Pourquoi c’est utile ?**  
> - On ne se fie **jamais** au client (Flutter) pour la sécurité.  
> - Même si un utilisateur modifie le code Flutter, il ne pourra pas voir ou modifier des données non autorisées.

---

## 2️⃣ Prérequis : activer RLS sur les tables

```sql
-- Activer RLS sur chaque table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE annonces ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE emplois_temps ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocs ENABLE ROW LEVEL SECURITY;
ALTER TABLE salles ENABLE ROW LEVEL SECURITY;
```

---

## 3️⃣ Comment Supabase connaît le rôle de l’utilisateur ?

Quand un utilisateur se connecte via **Supabase Auth**, Supabase crée un **JWT token** contenant :
- `sub` = l’UUID de l’utilisateur
- `role` = le rôle que tu stockes dans la table `users` (ex: `etudiant`, `enseignant`, `admin`)

> **Astuce** : tu peux ajouter une **custom claim** `app_role` dans le JWT via un trigger PostgreSQL.

---

## 4️⃣ Policies par table (exemples)

### 4.1 Table `users`

```sql
-- Tout le monde peut voir son propre profil
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid()::text = id::text);

-- Seul un admin peut voir tous les profils
CREATE POLICY "Admins can view all users" ON users
  FOR SELECT USING (auth.jwt() ->> 'app_role' = 'admin');

-- Seul un admin peut modifier les utilisateurs
CREATE POLICY "Admins can update users" ON users
  FOR UPDATE USING (auth.jwt() ->> 'app_role' = 'admin');

-- Personne ne peut supprimer (ou tu peux autoriser admin)
CREATE POLICY "No one can delete users" ON users
  FOR DELETE USING (false);
```

---

### 4.2 Table `annonces`

```sql
-- Tout le monde peut lire les annonces qui lui sont destinées
CREATE POLICY "Users can read allowed announcements" ON annonces
  FOR SELECT USING (
    target = 'tous' OR
    (target = 'etudiants' AND auth.jwt() ->> 'app_role' = 'etudiant') OR
    (target = 'enseignants' AND auth.jwt() ->> 'app_role' = 'enseignant') OR
    (auth.jwt() ->> 'app_role' = 'admin')
  );

-- Enseignants et admins peuvent créer des annonces
CREATE POLICY "Teachers and admins can create announcements" ON annonces
  FOR INSERT WITH CHECK (
    auth.jwt() ->> 'app_role' IN ('enseignant', 'admin')
  );

-- Seul l’auteur (ou admin) peut modifier
CREATE POLICY "Authors or admins can update announcements" ON annonces
  FOR UPDATE USING (
    author_id = auth.uid()::text OR auth.jwt() ->> 'app_role' = 'admin'
  );
```

---

### 4.3 Table `documents`

```sql
-- Lecture : public OU ciblage OU admin
CREATE POLICY "Read allowed documents" ON documents
  FOR SELECT USING (
    is_public = true OR
    target = 'tous' OR
    (target = 'etudiants' AND auth.jwt() ->> 'app_role' = 'etudiant') OR
    (target = 'enseignants' AND auth.jwt() ->> 'app_role' = 'enseignant') OR
    (auth.jwt() ->> 'app_role' = 'admin')
  );

-- Seuls enseignants et admins peuvent publier
CREATE POLICY "Teachers and admins can upload documents" ON documents
  FOR INSERT WITH CHECK (
    auth.jwt() ->> 'app_role' IN ('enseignant', 'admin')
  );

-- Auteur ou admin peut modifier
CREATE POLICY "Authors or admins can update documents" ON documents
  FOR UPDATE USING (
    author_id = auth.uid()::text OR auth.jwt() ->> 'app_role' = 'admin'
  );
```

---

### 4.4 Table `emplois_temps`

```sql
-- Les étudiants voient les emplois du temps de leur filière
CREATE POLICY "Students can read schedule for their filiere" ON emplois_temps
  FOR SELECT USING (
    filiere IN (SELECT filiere FROM users WHERE id = auth.uid()::text) OR
    auth.jwt() ->> 'app_role' = 'admin'
  );

-- Les enseignants voient leurs propres cours
CREATE POLICY "Teachers can read own schedule" ON emplois_temps
  FOR SELECT USING (
    enseignant IN (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = auth.uid()::text) OR
    auth.jwt() ->> 'app_role' = 'admin'
  );

-- Seul un admin peut créer/modifier/supprimer
CREATE POLICY "Admins can manage schedule" ON emplois_temps
  FOR ALL USING (auth.jwt() ->> 'app_role' = 'admin');
```

---

### 4.5 Table `blocs` et `salles`

```sql
-- Lecture : tout le monde (public)
CREATE POLICY "Everyone can read blocks" ON blocs
  FOR SELECT USING (true);

CREATE POLICY "Everyone can read rooms" ON salles
  FOR SELECT USING (true);

-- Seul un admin peut gérer
CREATE POLICY "Admins can manage blocks" ON blocs
  FOR ALL USING (auth.jwt() ->> 'app_role' = 'admin');

CREATE POLICY "Admins can manage rooms" ON salles
  FOR ALL USING (auth.jwt() ->> 'app_role' = 'admin');
```

---

## 5️⃣ Ajouter une custom claim `app_role` dans le JWT

Pour que les policies puissent lire `auth.jwt() ->> 'app_role'`, ajoute un trigger PostgreSQL :

```sql
-- Créer une fonction pour enrichir le JWT
CREATE OR REPLACE FUNCTION public.set_app_role()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.raw_user_meta_data = COALESCE(NEW.raw_user_meta_data, '{}')::jsonb
      || jsonb_build_object('app_role', NEW.raw_user_meta_data->>'app_role');
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger sur auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.set_app_role();
```

> **Alternative** : stocke le rôle dans une table `public.profiles` et lis-le dans les policies.

---

## 6️⃣ Bonnes pratiques pour un projet universitaire

### ✅ Toujours activer RLS
- Par défaut, sans RLS, tout le monde peut tout faire.

### ✅ Principe du moindre privilège
- Donne **juste ce dont il a besoin** (ex: étudiants ne modifient pas les emplois du temps).

### ✅ Utiliser des policies explicites
- Nomme chaque policy de manière claire (`Users can read own profile`).

### ✅ Tester les policies
- Utilise **Supabase CLI** : `supabase db diff` et `supabase db push`.

### ✅ Ne pas se fier au client
- Même si le code Flutter vérifie, **RLS est la source de vérité**.

### ✅ Logs et audits
- Active les logs Supabase pour voir qui fait quoi.

---

## 7️⃣ Résumé pour soutenance

> **“Dans CampusConnect, on sécurise les données côté base de données avec Supabase RLS.  
> Chaque table a des policies qui filtrent selon le rôle JWT (étudiant/enseignant/admin).  
> Ainsi, même si un utilisateur modifie le code Flutter, il ne pourra pas voir ou modifier des données non autorisées.”**

---

## 8️⃣ Commandes utiles

```bash
# Activer RLS
supabase db push --schema=public

# Vérifier les policies
supabase db diff --schema=public

# Lancer le seed (données de test)
supabase db seed
```

---

## 9️⃣ Ressources

- [Supabase RLS docs](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL policies](https://www.postgresql.org/docs/current/sql-createpolicy.html)

---

**Fin du guide RLS CampusConnect.**
