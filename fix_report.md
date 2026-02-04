# Rapport de Correction : Erreur d'Inscription CampusConnect

## 🔍 Analyse Diagnostique
L'erreur **"Database error saving new user"** lors de l'inscription était due à un blocage au niveau de la base de données (PostgreSQL) et non du code Flutter.

**Causes identifiées :**
1.  **Conflit de Données (Trigger vs Client)** :
    *   Le code Flutter (`auth.signUp`) envoie un jeu de métadonnées minimal (`role`, `nom`, `prénom`).
    *   Le code Flutter tente *ensuite* de compléter le profil via un `upsert` dans `SupabaseAuthService.dart`.
    *   **Le Problème** : Le Trigger database s'exécute *immédiatement* après `signUp`. Il essayait d'insérer une ligne dans `public.profiles` avec des champs vides (ex: `faculty_id` était `NULL` car non envoyé dans le `signUp`).
2.  **Contraintes Trop Strictes** : La table `profiles` avait des contraintes `NOT NULL` sur `faculty_id` (et potentiellement d'autres).
3.  **Résultat** : Le Trigger échouait à cause de la contrainte `NOT NULL`, ce qui annulait toute la transaction d'inscription (rollback).

## 🛠️ La Solution (Sans toucher à l'UI)
Le script SQL `fix_registration.sql` corrige cela en adoptant une approche "Permissive Initial, Strict Validation Later".

### Ce que fait le script :
1.  **Relâchement des Contraintes** : Rend `faculty_id`, `department_id`, `service_id` **NULLABLE**. Cela permet au Trigger de créer un profil "squelette" valide même sans ces infos.
2.  **Trigger Robuste** : 
    *   Réécrit `handle_new_user` pour gérer les clés manquantes sans crasher (`COALESCE`, `BEGIN/EXCEPTION`).
    *   Logique métier intégrée : Force `department_id = NULL` pour les Enseignants (règle Labé).
    *   Sécurise le parsing des types (UUID vs BigInt).
3.  **RLS Simplifié** : Remet à plat les politiques de sécurité pour garantir que le client Flutter a le droit de faire son `upsert` (mise à jour du profil) juste après l'inscription.

## ✅ Checklist de Vérification
Après avoir exécuté le script SQL, vérifiez les points suivants :

- [ ] **Table Profiles** : Les colonnes `faculty_id` et `department_id` acceptent désormais les valeurs NULL.
- [ ] **Inscription Étudiant** : Crée un compte, vérifie que le profil est créé ET que `faculty_id` est bien rempli (grâce à l'upsert du client qui suit).
- [ ] **Inscription Enseignant** : Crée un compte, vérifie que `department_id` est bien NULL en base.
- [ ] **Inscription Administratif** : Crée un compte, vérifie que `service_id` est bien enregistré.

## ⚠️ Ce qu'il ne faut PAS faire avant le rebuild
Pour garantir que cette correction tienne :

1.  **NE PAS remettre `NOT NULL`** sur les colonnes de `profiles` sans avoir d'abord modifié le code Flutter pour envoyer TOUTES les infos dans le `metadata` du `signUp`.
2.  **NE PAS supprimer la policy "Users can update own profile"**, sinon l'étape 2 de l'inscription (l'upsert client) échouera.
3.  **NE PAS modifier le code Flutter** `modern_register_screen.dart` pour l'instant. L'architecture actuelle (Inscription Auth -> Update Profile) est valide tant que la base l'accepte.
