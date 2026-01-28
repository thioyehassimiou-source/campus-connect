# CampusConnect

Application mobile universitaire pour centraliser les informations académiques et faciliter la communication au sein du campus.

## 🎯 Objectifs

- Centraliser les informations du campus en une seule plateforme
- Faciliter la communication entre étudiants, enseignants et administration
- Améliorer l'accès aux emplois du temps, annonces et documents
- Réduire les déplacements et pertes de temps liés aux démarches administratives

## 🚀 Fonctionnalités Implémentées

### ✅ Authentification et Profils
- Inscription et connexion sécurisées avec Firebase
- Gestion des profils utilisateurs (étudiant, enseignant, admin)
- Modification des informations personnelles
- Photo de profil

### ✅ Emploi du Temps
- Consultation des emplois du temps avec calendrier interactif
- Filtrage par date et par cours
- Support des différents types de cours (CM, TD, TP, Examens)
- Informations sur les salles et enseignants

### ✅ Notes et Résultats
- Affichage des notes par matière
- Calcul automatique de la moyenne générale
- Support des coefficients
- Commentaires des enseignants
- Filtrage par cours

### ✅ Annonces Officielles
- Système d'annonces avec priorités (basse, moyenne, haute, urgente)
- Ciblage des annonces (tous, étudiants, enseignants)
- Support des pièces jointes
- Date d'expiration des annonces
- Création d'annonces pour les administrateurs

### ✅ Interface Utilisateur
- Design moderne et intuitif avec Material Design
- Navigation par onglets
- Thème cohérent
- Interface responsive

## 🛠 Technologies Utilisées

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Base de données**: Cloud Firestore
- **Navigation**: Go Router
- **State Management**: BLoC Pattern
- **UI Components**: Material Design 3

## 📁 Structure du Projet

```
lib/
├── core/
│   ├── constants/       # Constantes de l'application
│   ├── services/        # Services Firebase
│   ├── themes/          # Thèmes et styles
│   └── utils/           # Utilitaires
├── features/
│   ├── auth/            # Authentification
│   ├── profile/         # Gestion des profils
│   ├── schedule/        # Emploi du temps
│   ├── grades/          # Notes et résultats
│   ├── documents/       # Documents
│   ├── announcements/   # Annonces
│   └── messages/        # Messagerie
├── shared/
│   ├── models/          # Modèles de données
│   ├── widgets/         # Widgets réutilisables
│   └── utils/           # Utilitaires partagés
└── screens/             # Écrans principaux
```

## 🚦 Installation

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd campusconnect
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer Firebase**
   - Créer un projet Firebase
   - Ajouter le fichier `google-services.json` dans `android/app/`
   - Configurer Authentication, Firestore et Storage

4. **Lancer l'application**
   ```bash
   flutter run
   ```

## 📱 Utilisateurs Cibles

- **Étudiants**: Consultation des emplois du temps, notes, annonces
- **Enseignants**: Gestion des cours, notes, annonces
- **Administration**: Gestion complète de la plateforme

## 🔐 Sécurité

- Authentification sécurisée avec Firebase
- Rôles et permissions appropriés
- Validation des données côté client et serveur

## 🌟 Fonctionnalités Futures

- Gestion des documents (cours, TD, examens)
- Messagerie interne
- Notifications push en temps réel
- Paiement des frais universitaires
- Système de signalement et feedback
- Forum étudiant
- Version web

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 📞 Contact

Pour toute question ou suggestion, veuillez contacter l'équipe de développement.

---

**CampusConnect** - Connecter votre campus, simplifier votre vie universitaire 🎓
