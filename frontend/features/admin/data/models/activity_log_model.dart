/// Représente une entrée dans le journal d'activité des administrateurs.
class ActivityLogModel {
  final String id;
  final String adminId;
  final String? adminName;
  final String action;
  final String? targetType;
  final String? targetId;
  final Map<String, dynamic>? details;
  final DateTime createdAt;

  const ActivityLogModel({
    required this.id,
    required this.adminId,
    this.adminName,
    required this.action,
    this.targetType,
    this.targetId,
    this.details,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] ?? '',
      adminId: json['admin_id'] ?? '',
      adminName: json['admin_name'],
      action: json['action'] ?? '',
      targetType: json['target_type'],
      targetId: json['target_id'],
      details: json['details'] is Map ? Map<String, dynamic>.from(json['details']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'admin_id': adminId,
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
        'details': details,
      };

  /// Retourne un libellé lisible pour l'action.
  String get actionLabel {
    switch (action) {
      case 'create_user':
        return 'Création utilisateur';
      case 'update_user':
        return 'Modification utilisateur';
      case 'delete_user':
        return 'Suppression utilisateur';
      case 'toggle_user_status':
        return 'Changement statut utilisateur';
      case 'validate_schedule':
        return 'Validation créneau';
      case 'reject_schedule':
        return 'Rejet créneau';
      case 'create_announcement':
        return 'Annonce publiée';
      case 'create_filiere':
        return 'Filière créée';
      case 'update_room':
        return 'Salle modifiée';
      default:
        return action;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} jours';
  }
}
