import 'package:flutter/foundation.dart';

enum ServiceCategory {
  GOVERNANCE, // Rectorat, etc.
  ADMIN,      // Scolarité, DRH, etc.
  SUPPORT,    // Bibliothèque, CRI, etc.
  ACADEMIC,   // Facultés via référence, Recherche
  OTHER
}

class InstitutionalService {
  final String id;
  final String nom;
  final String? description;
  final ServiceCategory category;
  final String? parentId;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final String? email;
  final String? telephone;
  final String? localisation;
  final String? horaires;
  final String? siteWeb;

  InstitutionalService({
    required this.id,
    required this.nom,
    this.description,
    this.category = ServiceCategory.OTHER,
    this.parentId,
    this.metadata = const {},
    this.isActive = true,
    this.email,
    this.telephone,
    this.localisation,
    this.horaires,
    this.siteWeb,
  });

  factory InstitutionalService.fromMap(Map<String, dynamic> map) {
    return InstitutionalService(
      id: map['id'],
      nom: map['nom'],
      description: map['description'],
      category: _parseCategory(map['category']),
      parentId: map['parent_id'],
      metadata: map['metadata'] ?? {},
      isActive: map['is_active'] ?? true,
      email: map['email'],
      telephone: map['telephone'],
      localisation: map['localisation'],
      horaires: map['horaires'],
      siteWeb: map['site_web'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'category': category.name,
      'parent_id': parentId,
      'metadata': metadata,
      'is_active': isActive,
      'email': email,
      'telephone': telephone,
      'localisation': localisation,
      'horaires': horaires,
      'site_web': siteWeb,
    };
  }

  static ServiceCategory _parseCategory(String? category) {
    if (category == null) return ServiceCategory.OTHER;
    try {
      return ServiceCategory.values.firstWhere(
        (e) => e.name == category.toUpperCase(),
        orElse: () => ServiceCategory.OTHER,
      );
    } catch (_) {
      return ServiceCategory.OTHER;
    }
  }
}
