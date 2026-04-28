import 'package:campusconnect/core/utils/app_utils.dart';

class Validators {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!AppUtils.isValidEmail(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  // Confirm password validator
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  // Name validator
  static String? validateName(String? value, {String fieldName = 'nom'}) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre $fieldName';
    }
    if (value.length < 2) {
      return 'Le $fieldName doit contenir au moins 2 caractères';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$').hasMatch(value)) {
      return 'Le $fieldName ne peut contenir que des lettres';
    }
    return null;
  }

  // Phone validator
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (!AppUtils.isValidPhone(value)) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }
    return null;
  }

  // Required field validator
  static String? validateRequired(String? value, {String fieldName = 'champ'}) {
    if (value == null || value.isEmpty) {
      return 'Le champ $fieldName est requis';
    }
    return null;
  }

  // Number validator
  static String? validateNumber(String? value, {String fieldName = 'nombre'}) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un $fieldName';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le $fieldName doit être un nombre valide';
    }
    return null;
  }

  // Positive number validator
  static String? validatePositiveNumber(String? value, {String fieldName = 'nombre'}) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un $fieldName';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Le $fieldName doit être un nombre valide';
    }
    if (number <= 0) {
      return 'Le $fieldName doit être positif';
    }
    return null;
  }

  // Range validator
  static String? validateRange(
    String? value, {
    double min = 0.0,
    double max = 20.0,
    String fieldName = 'valeur',
  }) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une $fieldName';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'La $fieldName doit être un nombre valide';
    }
    if (number < min || number > max) {
      return 'La $fieldName doit être entre $min et $max';
    }
    return null;
  }

  // URL validator
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une URL';
    }
    if (!RegExp(r'^https?://').hasMatch(value)) {
      return 'L\'URL doit commencer par http:// ou https://';
    }
    return null;
  }

  // File size validator
  static String? validateFileSize(int? size, int maxSizeInBytes) {
    if (size == null) {
      return 'Taille du fichier invalide';
    }
    if (size > maxSizeInBytes) {
      return 'La taille du fichier ne doit pas dépasser ${AppUtils.formatFileSize(maxSizeInBytes)}';
    }
    return null;
  }

  // Student ID validator
  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro étudiant';
    }
    if (!RegExp(r'^[0-9]{8,12}$').hasMatch(value)) {
      return 'Le numéro étudiant doit contenir entre 8 et 12 chiffres';
    }
    return null;
  }

  // Department validator
  static String? validateDepartment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner un département';
    }
    return null;
  }

  // Course name validator
  static String? validateCourseName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le nom du cours';
    }
    if (value.length < 3) {
      return 'Le nom du cours doit contenir au moins 3 caractères';
    }
    return null;
  }

  // Grade validator
  static String? validateGrade(String? value, double maxValue) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une note';
    }
    final grade = double.tryParse(value);
    if (grade == null) {
      return 'La note doit être un nombre valide';
    }
    if (grade < 0 || grade > maxValue) {
      return 'La note doit être entre 0 et $maxValue';
    }
    return null;
  }

  // Coefficient validator
  static String? validateCoefficient(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un coefficient';
    }
    final coefficient = double.tryParse(value);
    if (coefficient == null) {
      return 'Le coefficient doit être un nombre valide';
    }
    if (coefficient <= 0) {
      return 'Le coefficient doit être positif';
    }
    if (coefficient > 10) {
      return 'Le coefficient ne peut pas dépasser 10';
    }
    return null;
  }

  // Title validator
  static String? validateTitle(String? value, {int minLength = 3, int maxLength = 100}) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un titre';
    }
    if (value.length < minLength) {
      return 'Le titre doit contenir au moins $minLength caractères';
    }
    if (value.length > maxLength) {
      return 'Le titre ne peut pas dépasser $maxLength caractères';
    }
    return null;
  }

  // Description validator
  static String? validateDescription(String? value, {int maxLength = 500}) {
    if (value != null && value.length > maxLength) {
      return 'La description ne peut pas dépasser $maxLength caractères';
    }
    return null;
  }

  // Date validator
  static String? validateDate(DateTime? value, {bool allowPast = true, bool allowFuture = true}) {
    if (value == null) {
      return 'Veuillez sélectionner une date';
    }
    
    final now = DateTime.now();
    
    if (!allowPast && value.isBefore(now)) {
      return 'La date ne peut pas être dans le passé';
    }
    
    if (!allowFuture && value.isAfter(now)) {
      return 'La date ne peut pas être dans le futur';
    }
    
    return null;
  }

  // Time validator
  static String? validateTime(TimeOfDay? value) {
    if (value == null) {
      return 'Veuillez sélectionner une heure';
    }
    return null;
  }
}
