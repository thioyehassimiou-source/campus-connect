# CampusConnect - Architecture Technique Complète

## Vue d’ensemble
CampusConnect est une application mobile Flutter connectée à Firebase Firestore, conçue pour l’Université de Labé. Elle suit une architecture propre (Clean Architecture) avec BLoC pour la gestion d’état.

## Structure des dossiers
```
lib/
├── core/                          # Core utilities
│   ├── services/
│   │   ├── auth_service.dart      # Firebase Auth
│   │   └── storage_service.dart  # Firebase Storage
│   └── themes/
│       └── app_theme.dart         # App themes
├── features/                      # Feature modules
│   ├── auth/                      # Authentication
│   │   ├── core/services/
│   │   │   └── auth_service.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── screens/
│   │           └── login_screen.dart
│   ├── home/                      # Dashboard by role
│   │   └── presentation/screens/
│   │       └── dashboard_screen.dart
│   ├── emploi_temps/              # Schedule management
│   ├── annonces/                  # Announcements
│   ├── documents/                 # Documents
│   ├── notes/                     # Grades
│   ├── filières/                  # Academic programs
│   ├── campus_map/                # Campus map
│   ├── salles/                    # Room management
│   ├── services_universitaires/   # University services
│   └── notifications/            # Push notifications
├── models/                        # Data models
│   ├── user.dart                  # User hierarchy
│   ├── academique.dart            # Academic entities
│   ├── infrastructure.dart        # Campus infrastructure
│   ├── communication.dart         # Communication
│   └── enums.dart                 # Enums
├── services/                      # Data services
│   ├── user_service.dart          # User CRUD
│   ├── academique_service.dart    # Academic CRUD
│   ├── communication_service.dart  # Communication CRUD
│   └── infrastructure_service.dart # Infrastructure CRUD
└── data/                          # Data initialization
    └── init_data.dart             # Sample data
```

## Architecture des couches

### 1. Présentation (Presentation Layer)
- **Écrans** : UI Flutter
- **BLoCs** : Gestion d’état (Business Logic Component)
- **Events/States** : Communication avec la couche domaine

### 2. Domaine (Domain Layer)
- **Modèles** : Entités métier (User, Faculté, Salle, etc.)
- **Enums** : Types fixes (Role, TypeSalle, etc.)

### 3. Données (Data Layer)
- **Services** : Accès aux données (Firebase Firestore)
- **Repository pattern** : Abstraction de la source de données

## Flux de données typique
```
UI (Screen) → BLoC → Event → Service → Firestore
                ↑
           State ← ← ← ← ← ← ← ← ← ← ←
```

## Base de données (Firebase Firestore)

### Collections principales
- `users` : Utilisateurs (étudiants, enseignants, admin)
- `facultes` : Facultés universitaires
- `departements` : Départements académiques
- `filieres` : Filières d’études
- `blocs` : Blocs du campus
- `salles` : Salles et amphithéâtres
- `emplois_temps` : Emplois du temps
- `notes` : Notes et résultats
- `documents` : Documents pédagogiques
- `annonces` : Annonces campus
- `services` : Services administratifs

## Parcours fonctionnels

### Étudiant
1. **Connexion** → Firebase Auth → Dashboard étudiant
2. **Emploi du temps** → Consultation par filière
3. **Notes** → Consultation des résultats
4. **Documents** → Téléchargement par filière
5. **Annonces** → Consultation générale
6. **Carte du campus** → Navigation dans les blocs/salles
7. **Services** → Informations administratives

### Enseignant
1. **Connexion** → Dashboard enseignant
2. **Publier documents** → Upload vers Storage + Firestore
3. **Publier annonces** → Création dans Firestore
4. **Emploi du temps** → Consultation
5. **Filières** → Consultation des programmes

### Administrateur
1. **Connexion sécurisée** → Dashboard admin
2. **Gestion utilisateurs** → CRUD sur users
3. **Gestion salles** → CRUD sur salles/blocs
4. **Annonces officielles** → Publication ciblée
5. **Services** → Mise à jour des informations

## Sécurité
- **Firebase Authentication** : Authentification sécurisée
- **Règles Firestore** : Contrôle d’accès par rôle
- **Validation locale** : Forms validation côté client

## Notifications
- **Firebase Cloud Messaging** : Notifications push
- **Topics** : Par rôle (étudiants, enseignants, admin)
- **Gestion des permissions** : Demande à l’utilisateur

## Stockage
- **Firebase Storage** : Documents pédagogiques
- **URLs signées** : Accès sécurisé aux fichiers
- **Métadonnées** : Type de document, propriétaire

## Performance
- **Lazy loading** : Chargement à la demande
- **Pagination** : Listes paginées
- **Cache local** : Optimisation des requêtes

## Tests
- **Unit tests** : BLoCs et services
- **Widget tests** : Composants UI
- **Integration tests** : Flux complets

## Déploiement
- **Android** : APK via Firebase App Distribution
- **iOS** : IPA via TestFlight
- **Web** : Hostage sur Firebase Hosting

## Monitoring
- **Firebase Crashlytics** : Rapports d’erreurs
- **Firebase Analytics** : Usage et performances
- **Firebase Performance** : Monitoring applicatif

Cette architecture garantit :
- **Maintenabilité** : Séparation claire des responsabilités
- **Scalabilité** : Modulaire et extensible
- **Testabilité** : Injection de dépendances
- **Performance** : Optimisations natives Firebase
