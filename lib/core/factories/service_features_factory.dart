import 'package:flutter/material.dart';

enum ServiceActionType {
  navigation,
  url,
  phone,
  email,
  snackbar
}

class ServiceAction {
  final String label;
  final IconData icon;
  final ServiceActionType type;
  final String? payload;
  final Color? color;

  const ServiceAction({
    required this.label,
    required this.icon,
    required this.type,
    this.payload,
    this.color,
  });
}

class ServiceFeaturesFactory {
  static List<ServiceAction> getActionsForService(String serviceName) {
    final name = serviceName.toLowerCase();

    if (name.contains('scolarité')) {
      return [
        const ServiceAction(
          label: 'Relevé de notes',
          icon: Icons.file_copy_outlined,
          type: ServiceActionType.snackbar,
          payload: 'Demande de relevé envoyée au service.',
        ),
         const ServiceAction(
          label: 'Mes inscriptions',
          icon: Icons.school_outlined,
          type: ServiceActionType.snackbar,
          payload: 'Redirection vers le module inscriptions...',
        ),
        const ServiceAction(
          label: 'Cursus',
          icon: Icons.history_edu,
          type: ServiceActionType.navigation,
          payload: '/cursus',
        ),
      ];
    } 
    
    if (name.contains('médical') || name.contains('santé') || name.contains('infirmerie')) {
      return [
         const ServiceAction(
          label: 'Prendre RDV',
          icon: Icons.calendar_today,
          type: ServiceActionType.url,
          payload: 'https://univ-labe.edu.gn/sante/rdv',
        ),
        const ServiceAction(
          label: 'Urgences',
          icon: Icons.local_hospital,
          type: ServiceActionType.phone,
          payload: '112', // Urgence
          color: Colors.red,
        ),
         const ServiceAction(
          label: 'Pharmacie',
          icon: Icons.medical_services_outlined,
          type: ServiceActionType.snackbar,
          payload: 'Liste des pharmacies de garde affichée.',
        ),
      ];
    }

    if (name.contains('bibliothèque')) {
      return [
        const ServiceAction(
          label: 'Catalogue',
          icon: Icons.menu_book,
          type: ServiceActionType.url,
          payload: 'https://bu.univ-labe.edu.gn/catalogue',
        ),
         const ServiceAction(
          label: 'Réserver salle',
          icon: Icons.meeting_room_outlined,
          type: ServiceActionType.url,
          payload: 'https://bu.univ-labe.edu.gn/reservation',
        ),
      ];
    }
    
    if (name.contains('informatique') || name.contains('it')) {
      return [
        const ServiceAction(
          label: 'Code Wi-Fi',
          icon: Icons.wifi,
          type: ServiceActionType.snackbar,
          payload: 'Votre code Wi-Fi est disponible dans votre profil.',
        ),
         const ServiceAction(
          label: 'Support',
          icon: Icons.support_agent,
          type: ServiceActionType.email,
          payload: 'support@univ-labe.edu.gn',
        ),
      ];
    }

    return [];
  }
}
