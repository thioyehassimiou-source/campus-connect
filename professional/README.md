# CampusConnect - Structure du Projet

## 📁 Structure des Dossiers

```
lib/
├── main.dart                           # Point d'entrée de l'application
├── core/                              # Configuration et utilitaires globaux
│   ├── config/
│   │   └── supabase_config.dart       # Configuration Supabase
│   ├── router/
│   │   └── app_router.dart            # Configuration GoRouter
│   ├── services/
│   │   └── supabase_service.dart      # Service Supabase centralisé
│   └── theme/
│       └── app_theme.dart             # Thème de l'application
├── features/                          # Fonctionnalités par domaine
│   ├── auth/                          # Authentification
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart  # State management auth
│   │   │   └── screens/
│   │   │       ├── splash_screen.dart
│   │   │       ├── login_screen.dart
│   │   │       └── register_screen.dart
│   │   └── domain/                    # Logique métier auth
│   │       ├── models/
│   │       └── repositories/
│   ├── home/                          # Écran principal
│   │   └── presentation/
│   │       └── screens/
│   │           └── home_screen.dart
│   ├── profile/                       # Profil utilisateur
│   │   └── presentation/
│   │       └── screens/
│   │           └── profile_screen.dart
│   ├── schedule/                      # Emploi du temps
│   ├── grades/                        # Notes
│   ├── announcements/                 # Annonces
│   └── documents/                     # Documents
└── shared/                            # Composants partagés
    ├── widgets/
    ├── models/
    └── utils/

assets/
├── images/                            # Images de l'application
├── icons/                             # Icônes
└── fonts/                             # Polices personnalisées
```

## 🏗️ Architecture

### Clean Architecture
- **Presentation Layer** : UI, screens, widgets, providers
- **Domain Layer** : Logique métier, modèles, use cases
- **Data Layer** : Services, repositories, sources de données

### State Management
- **Riverpod** pour la gestion d'état réactive
- **Providers** pour chaque fonctionnalité
- **StateNotifier** pour la logique complexe

### Navigation
- **GoRouter** pour la navigation déclarative
- **Routes protégées** basées sur l'authentification
- **Deep linking** supporté

## 🔧 Configuration Supabase

1. **Créer un projet** sur [supabase.com](https://supabase.com)
2. **Copier les clés** dans `lib/core/config/supabase_config.dart`
3. **Configurer les tables** dans le dashboard Supabase

### Tables requises
```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  role VARCHAR(20) DEFAULT 'etudiant',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Autres tables à ajouter selon les besoins
```

## 🚀 Lancement du Projet

```bash
# Installation des dépendances
flutter pub get

# Lancement en mode développement
flutter run

# Build pour Android
flutter build apk --release
```

## 📱 Priorités Android

### Configuration Android
- `minSdkVersion: 21` (Android 5.0+)
- `targetSdkVersion: 34` (Android 14)
- Support des permissions nécessaires

### Optimisations
- **Performance** : Lazy loading, pagination
- **Offline** : Cache local avec SharedPreferences
- **Sécurité** : Flutter Secure Storage

## 🎯 Fonctionnalités Implémentées

### ✅ Authentification
- Inscription/Connexion
- Validation des formulaires
- Gestion des erreurs
- Session persistante

### ✅ Navigation
- Splash screen intelligent
- Routes protégées
- Navigation fluide
- Deep linking

### ✅ Base de Données
- Service Supabase centralisé
- CRUD générique
- Gestion des erreurs
- Logging intégré

### 🔄 Fonctionnalités à Développer
- Emploi du temps
- Notes et bulletins
- Annonces universitaires
- Documents partagés
- Messagerie interne

## 📝 Bonnes Pratiques

### Code Quality
- **Linter** activé avec `flutter_lints`
- **Formatters** avec `dart format`
- **Tests** unitaires et widgets
- **Documentation** des APIs

### Performance
- **State management** optimisé
- **Image caching** avec cached_network_image
- **Lazy loading** des listes
- **Memory management**

### Sécurité
- **Environment variables** pour les clés
- **Input validation** stricte
- **Secure storage** pour les tokens
- **HTTPS** obligatoire

## 🔄 Évolution du Projet

Ce prototype est conçu pour être **évolutif** :
- Architecture modulaire
- Services découplés
- Tests automatisés
- Documentation complète

Chaque nouvelle fonctionnalité peut être ajoutée en suivant la structure établie.
