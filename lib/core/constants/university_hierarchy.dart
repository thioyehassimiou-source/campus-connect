/// Organisation réelle des services universitaires
/// Sert de structure de référence pour le réalisme institutionnel,
/// les permissions futures et le contexte de l'IA.
class UniversityHierarchy {
  // 1. Gouvernance centrale (Informatif)
  static const centralGovernance = {
    'Rectorat': ['Cabinet', 'Services rattachés'],
    'Vice-rectorats': ['VR Recherche', 'VR Pédagogie', 'VR Coopération'],
    'Secrétariat général': ['DSI', 'Services techniques'],
    'Conseil de l’université': [],
  };

  // 2. Services administratifs centraux (Déclaratifs)
  static const centralServices = {
    'SCOLARITE_CENTRALE': 'Service de la scolarité',
    'DAAF': 'Direction des affaires administratives et financières',
    'AGENCE_COMPTABLE': 'Agence comptable',
    'CONTROLE_FINANCIER': 'Contrôle financier',
    'DRH': 'Direction des ressources humaines',
    'COUV': 'Centre des œuvres universitaires',
    'MAINTENANCE': 'Service technique et maintenance',
    'SECURITE': 'Service d’ordre (sécurité)',
    'MEDICAL': 'Centre médical universitaire',
  };

  // 3. Services d’appui académique et technique (Fonctionnels)
  static const academicSupport = {
    'BIBLIOTHEQUE': 'Bibliothèque universitaire',
    'INFORMATIQUE': 'Centre informatique',
    'LABO': 'Laboratoires et ateliers',
    'EDITIONS': 'Éditions universitaires',
  };

  // 4. Services académiques rattachés (Périmètre académique)
  static const academicServices = {
    'SCOLARITE_FACULTE': 'Service de la scolarité (Faculté)',
    'SERVICE_DEPARTEMENT': 'Services de départements',
    'SERVICE_FACULTE': 'Services de facultés',
    'RECHERCHE': 'Service de la recherche',
    'COOPERATION': 'Coopération et relations extérieures',
    'POST_GRADUATION': 'Études avancées / post-graduation',
  };

  // Mapper les types de services pour le UserModel et la DB
  static const allServices = {
    ...centralServices,
    ...academicSupport,
    ...academicServices,
  };

  static List<String> get serviceTypes => allServices.keys.toList();

  static String? getServiceLabel(String type) => allServices[type];
}
