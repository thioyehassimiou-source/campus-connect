# CampusConnect Authentification

## 🚀 Lancement Rapide

```bash
cd auth/
flutter pub get
flutter run
```

## ⚙️ Configuration Supabase

1. **Créer un projet** sur [supabase.com](https://supabase.com)
2. **Copier les clés** dans `lib/core/config/supabase_config.dart`:
   ```dart
   static const String url = 'https://votre-projet.supabase.co';
   static const String anonKey = 'votre-cle-anon';
   ```

3. **Créer la table users** dans le dashboard Supabase:
   ```sql
   CREATE TABLE users (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     email VARCHAR(255) UNIQUE NOT NULL,
     first_name VARCHAR(100),
     last_name VARCHAR(100),
     role VARCHAR(20) DEFAULT 'etudiant',
     created_at TIMESTAMP DEFAULT NOW(),
     updated_at TIMESTAMP DEFAULT NOW()
   );
   ```

## 📱 Fonctionnalités

### ✅ LoginScreen
- Formulaire email + mot de passe
- Validation en temps réel
- Gestion des erreurs détaillées
- Affichage des messages de succès/erreur
- Redirection automatique après connexion

### ✅ RegisterScreen  
- Inscription complète avec nom, prénom, email, mot de passe
- Sélection du rôle (étudiant/enseignant)
- Confirmation de mot de passe
- Validation des champs
- Messages d'erreur spécifiques

### ✅ AuthProvider
- State management avec Riverpod
- Gestion des états (loading, error, success, authenticated)
- Messages d'erreur en français
- Persistance de session

### ✅ Navigation
- Routes protégées automatiquement
- Redirection intelligente
- GoRouter pour navigation déclarative

## 🎯 Cas d'Utilisation

### Inscription
1. Remplir le formulaire
2. Validation automatique
3. Création du compte Supabase
4. Message de succès
5. Redirection vers connexion

### Connexion
1. Saisir email + mot de passe
2. Validation des identifiants
3. Authentification Supabase
4. Redirection vers home

### Gestion des Erreurs
- Email invalide
- Mot de passe incorrect
- Email déjà utilisé
- Format d'email incorrect
- Erreurs réseau

## 🔧 Tests

### Test d'inscription
```bash
# Données de test
Email: test@universite.fr
Mot de passe: password123
Prénom: Test
Nom: User
Rôle: Étudiant
```

### Test de connexion
```bash
# Utiliser les mêmes identifiants
Email: test@universite.fr
Mot de passe: password123
```

## 📋 Checklist de Déploiement

- [ ] Configurer les clés Supabase
- [ ] Créer la table users
- [ ] Tester l'inscription
- [ ] Tester la connexion
- [ ] Vérifier la redirection
- [ ] Tester la déconnexion

## 🎨 Interface

- **Design Material 3**
- **Couleurs** : Bleu principal (#2196F3)
- **Responsive** : Adapté mobile
- **Animations** : Smooth transitions
- **Feedback** : Messages clairs

## 🔄 Évolution

Ce code est prêt pour être étendu avec :
- Emploi du temps
- Notes et bulletins
- Annonces universitaires
- Documents partagés
- Messagerie interne
