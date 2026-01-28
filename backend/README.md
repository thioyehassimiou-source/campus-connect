# CampusConnect Backend

Backend API pour l'application universitaire CampusConnect.

## 🏗️ Architecture

```
backend/
├── lib/
│   ├── config/          # Configuration (base de données, auth)
│   ├── models/          # Modèles de données
│   ├── routes/          # Routes API
│   ├── services/        # Services métier
│   ├── middleware/      # Middleware (auth, validation)
│   └── utils/           # Utilitaires
├── test/                # Tests
└── pubspec.yaml         # Dépendances
```

## 🚀 Technologies

- **Framework**: Dart avec Shelf
- **Base de données**: PostgreSQL (via Supabase)
- **Authentification**: JWT
- **API Documentation**: OpenAPI/Swagger

## 📡 Endpoints

### Authentification
- `POST /auth/register` - Inscription
- `POST /auth/login` - Connexion
- `POST /auth/logout` - Déconnexion
- `GET /auth/profile` - Profil utilisateur

### Utilisateurs
- `GET /users` - Liste des utilisateurs
- `GET /users/:id` - Détails utilisateur
- `PUT /users/:id` - Mise à jour utilisateur
- `DELETE /users/:id` - Suppression utilisateur

### Emploi du temps
- `GET /schedule` - Emploi du temps
- `POST /schedule` - Créer cours
- `PUT /schedule/:id` - Modifier cours
- `DELETE /schedule/:id` - Supprimer cours

### Notes
- `GET /grades` - Notes étudiant
- `POST /grades` - Ajouter note
- `PUT /grades/:id` - Modifier note

### Annonces
- `GET /announcements` - Liste des annonces
- `POST /announcements` - Créer annonce
- `PUT /announcements/:id` - Modifier annonce
- `DELETE /announcements/:id` - Supprimer annonce

### Documents
- `GET /documents` - Liste des documents
- `POST /documents` - Uploader document
- `GET /documents/:id/download` - Télécharger document

## 🗄️ Base de Données

### Collections principales
- `users` - Utilisateurs
- `schedules` - Emploi du temps
- `grades` - Notes
- `announcements` - Annonces
- `documents` - Documents
- `facultes` - Facultés
- `filieres` - Filières
- `salles` - Salles

## 🔐 Sécurité

- JWT tokens pour l'authentification
- Validation des entrées
- Rate limiting
- CORS configuré
- Rôles et permissions

## 🚀 Lancement

```bash
dart pub get
dart run bin/server.dart
```

## 🧪 Tests

```bash
dart test
```
