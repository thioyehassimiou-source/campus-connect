# CampusConnect Design System

## 🎨 Vue d'Ensemble

Le Design System de CampusConnect fournit une collection de composants réutilisables et cohérents pour garantir une expérience utilisateur uniforme dans toute l'application.

## 📦 Structure

```
lib/shared/widgets/
├── campus_design_system.dart     # Export principal
├── campus_button.dart             # Boutons (primary, secondary, outline, text)
├── campus_text_field.dart         # Champs de formulaire
├── campus_card.dart               # Cartes (elevated, outlined, filled)
├── campus_badge.dart              # Badges (types, statuts, priorités)
└── campus_icons.dart              # Icônes thématiques
```

## 🎯 Objectifs

- **Réutilisabilité** : Composants prêts à l'emploi
- **Cohérence** : Design uniforme dans toute l'application
- **Maintenance** : Modifications centralisées
- **Accessibilité** : Composants accessibles par défaut

## 🔧 Utilisation

### Import principal

```dart
import 'package:campusconnect/shared/widgets/campus_design_system.dart';
```

### Import individuel

```dart
import 'package:campusconnect/shared/widgets/campus_button.dart';
```

---

## 🎯 Boutons (CampusButton)

### Types disponibles

```dart
// Bouton primaire (bleu)
CampusButton.primary(
  text: 'Se connecter',
  onPressed: () => print('Action'),
)

// Bouton secondaire (vert)
CampusButton.secondary(
  text: 'Valider',
  onPressed: () => print('Action'),
)

// Bouton outline (bordure)
CampusButton.outline(
  text: 'Annuler',
  onPressed: () => print('Action'),
)

// Bouton texte
CampusButton.text(
  text: 'En savoir plus',
  onPressed: () => print('Action'),
)
```

### Tailles

```dart
CampusButton.primary(
  text: 'Petit',
  size: CampusButtonSize.small,
  onPressed: () => print('Action'),
)

CampusButton.primary(
  text: 'Moyen',
  size: CampusButtonSize.medium,
  onPressed: () => print('Action'),
)

CampusButton.primary(
  text: 'Grand',
  size: CampusButtonSize.large,
  onPressed: () => print('Action'),
)
```

### Avec icône

```dart
CampusButton.primary(
  text: 'Télécharger',
  icon: Icons.download,
  onPressed: () => print('Action'),
)
```

### État de chargement

```dart
CampusButton.primary(
  text: 'Chargement...',
  isLoading: true,
  onPressed: null, // Désactivé pendant le chargement
)
```

---

## 📝 Champs de Formulaire (CampusTextField)

### Champ de base

```dart
CampusTextField(
  label: 'Email',
  hint: 'nom@univ-campus.fr',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
)
```

### Champ mot de passe

```dart
CampusTextField(
  label: 'Mot de passe',
  hint: '•••••••••',
  isPassword: true,
  controller: _passwordController,
)
```

### Avec validation

```dart
CampusTextField(
  label: 'Nom',
  hint: 'Jean Dupont',
  errorText: _showError ? 'Ce champ est requis' : null,
  controller: _nameController,
)
```

### Tailles et variantes

```dart
// Tailles
CampusTextField(
  size: CampusTextFieldSize.small,
  label: 'Petit',
)

CampusTextField(
  size: CampusTextFieldSize.medium,
  label: 'Moyen',
)

CampusTextField(
  size: CampusTextFieldSize.large,
  label: 'Grand',
)

// Variantes
CampusTextField(
  variant: CampusTextFieldVariant.outlined,
  label: 'Outlined',
)

CampusTextField(
  variant: CampusTextFieldVariant.filled,
  label: 'Filled',
)

CampusTextField(
  variant: CampusTextFieldVariant.underline,
  label: 'Underline',
)
```

---

## 🃏 Cartes (CampusCard)

### Carte basique

```dart
CampusCard.elevated(
  child: Text('Contenu de la carte'),
)
```

### Avec header et footer

```dart
CampusCard.elevated(
  header: Text('Titre'),
  child: Text('Contenu'),
  footer: Text('Footer'),
)
```

### Carte cliquable

```dart
CampusCard.outlined(
  onTap: () => print('Carte cliquée'),
  child: Text('Carte cliquable'),
)
```

### Cartes spécialisées

```dart
// Carte d'information
CampusInfoCard(
  title: 'Service',
  subtitle: 'Description',
  icon: Icons.school,
  onTap: () => print('Action'),
)

// Carte de statistique
CampusStatCard(
  title: 'Étudiants',
  value: '1,247',
  subtitle: 'Total',
  icon: Icons.people,
)
```

---

## 🏷️ Badges (CampusBadge)

### Types de badges

```dart
// Badge primaire
CampusBadge.primary(
  text: 'Nouveau',
)

// Badge de succès
CampusBadge.success(
  text: 'Actif',
  icon: Icons.check,
)

// Badge d'erreur
CampusBadge.error(
  text: 'Erreur',
  icon: Icons.error,
)

// Badge outline
CampusBadge.outline(
  text: 'Disponible',
)
```

### Badges spécialisés

```dart
// Badge de statut
CampusStatusBadge(
  text: 'En cours',
  status: CampusStatus.pending,
)

// Badge de rôle
CampusRoleBadge(
  text: 'Étudiant',
  role: CampusRole.student,
)

// Badge de priorité
CampusPriorityBadge(
  text: 'Urgent',
  priority: CampusPriority.urgent,
)
```

---

## 🎨 Icônes (CampusIcons)

### Icônes thématiques

```dart
// Navigation
CampusIcons.home
CampusIcons.dashboard
CampusIcons.calendar
CampusIcons.profile

// Éducation
CampusIcons.school
CampusIcons.book
CampusIcons.exam
CampusIcons.grade

// Campus
CampusIcons.building
CampusIcons.location
CampusIcons.map
CampusIcons.library

// Communication
CampusIcons.email
CampusIcons.phone
CampusIcons.announcement
```

### Icônes thématiques stylisées

```dart
// Icônes avec couleur thématique
CampusThemedIcons.education()
CampusThemedIcons.library()
CampusThemedIcons.building()
CampusThemedIcons.email()

// Personnalisés
CampusThemedIcons.education(size: 32, color: CampusColors.primary)
```

---

## 🎨 Couleurs (CampusColors)

### Couleurs principales

```dart
CampusColors.primary      // #2563EB (Bleu)
CampusColors.secondary    // #10B981 (Vert)
CampusColors.accent       // #F59E0B (Orange)
CampusColors.error        // #EF4444 (Rouge)
CampusColors.warning      // #F59E0B (Orange)
CampusColors.success      // #10B981 (Vert)
CampusColors.info         // #3B82F6 (Bleu clair)
```

### Couleurs neutres

```dart
CampusColors.white        // #FFFFFF
CampusColors.black        // #000000
CampusColors.gray50       // #F9FAFB
CampusColors.gray100      // #F3F4F6
// ... jusqu'à gray900
```

### Couleurs de rôle

```dart
CampusColors.student      // #2563EB
CampusColors.teacher      // #10B981
CampusColors.admin        // #DC2626
```

---

## 📝 Styles de Texte (CampusTextStyles)

### Hiérarchie typographique

```dart
CampusTextStyles.h1          // 32px, w800
CampusTextStyles.h2          // 24px, w700
CampusTextStyles.h3          // 20px, w700
CampusTextStyles.h4          // 18px, w600
CampusTextStyles.bodyLarge   // 16px, w500
CampusTextStyles.body        // 14px, w400
CampusTextStyles.bodySmall   // 12px, w400
CampusTextStyles.caption      // 10px, w500
```

---

## 📏 Espacement (CampusSpacing)

```dart
CampusSpacing.xs           // 4px
CampusSpacing.sm           // 8px
CampusSpacing.md           // 16px
CampusSpacing.lg           // 24px
CampusSpacing.xl           // 32px
CampusSpacing.xxl          // 48px
```

---

## 🔄 Bordures Arrondies (CampusBorderRadius)

```dart
CampusBorderRadius.sm       // 4px
CampusBorderRadius.md       // 8px
CampusBorderRadius.lg       // 12px
CampusBorderRadius.xl       // 16px
CampusBorderRadius.xxl      // 20px
CampusBorderRadius.full     // 50px (cercle)
```

---

## 🚀 Bonnes Pratiques

### 1. Consistance

Utilisez toujours les composants du Design System plutôt que de créer des widgets personnalisés.

### 2. Accessibilité

Les composants incluent des sémantiques appropriées et des contrastes suffisants.

### 3. Performance

Les composants sont optimisés pour éviter les reconstructions inutiles.

### 4. Flexibilité

Les composants acceptent des paramètres de personnalisation tout en maintenant la cohérence.

---

## 🔧 Personnalisation

### Surcharge des couleurs

```dart
CampusButton.primary(
  text: 'Personnalisé',
  onPressed: () => print('Action'),
).copyWith(
  // Personnalisation si nécessaire
)
```

### Extension des composants

```dart
class CustomButton extends CampusButton {
  // Extension avec fonctionnalités spécifiques
}
```

---

## 📚 Exemples Complets

### Formulaire de connexion

```dart
Column(
  children: [
    CampusTextField(
      label: 'Email',
      hint: 'nom@univ-campus.fr',
      keyboardType: TextInputType.emailAddress,
    ),
    const SizedBox(height: CampusSpacing.md),
    CampusTextField(
      label: 'Mot de passe',
      hint: '•••••••••',
      isPassword: true,
    ),
    const SizedBox(height: CampusSpacing.lg),
    CampusButton.primary(
      text: 'Se connecter',
      isFullWidth: true,
      onPressed: () => print('Connexion'),
    ),
  ],
)
```

### Carte de service

```dart
CampusCard.elevated(
  child: Column(
    children: [
      CampusThemedIcons.library(size: 48),
      const SizedBox(height: CampusSpacing.md),
      Text(
        'Bibliothèque',
        style: CampusTextStyles.h4,
      ),
      const SizedBox(height: CampusSpacing.sm),
      Text(
        'Ressources et salles d\'étude',
        style: CampusTextStyles.body,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: CampusSpacing.md),
      CampusBadge.secondary(
        text: 'Ouvert',
        icon: Icons.access_time,
      ),
    ],
  ),
)
```

---

## 🔄 Maintenance

Pour modifier le Design System :

1. **Couleurs** : Modifiez les constantes dans `CampusColors`
2. **Styles** : Ajustez les `CampusTextStyles`
3. **Composants** : Étendez les classes existantes
4. **Documentation** : Mettez à jour ce fichier

---

## 📱 Support

Le Design System est conçu pour fonctionner sur toutes les plateformes supportées par Flutter (iOS, Android, Web, Desktop).

Pour toute question ou suggestion, contactez l'équipe de design.
