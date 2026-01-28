import 'package:flutter/material.dart';

class ModernServicesScreen extends StatefulWidget {
  const ModernServicesScreen({super.key});

  @override
  State<ModernServicesScreen> createState() => _ModernServicesScreenState();
}

class _ModernServicesScreenState extends State<ModernServicesScreen> {

  final List<Map<String, dynamic>> services = const [
    {
      'name': 'Scolarité',
      'description': 'Inscriptions, relevés de notes, attestations, diplômes',
      'icon': Icons.school,
      'color': Color(0xFF2563EB),
      'phone': '01 23 45 67 89',
      'email': 'scolarite@univ-campus.fr',
      'location': 'Bloc A - Étage 1',
      'hours': 'Lun-Ven: 8h-17h',
      'website': 'scolarite.univ-campus.fr',
    },
    {
      'name': 'Bibliothèque',
      'description': 'Prêt de livres, salles d\'étude, ressources numériques',
      'icon': Icons.library_books,
      'color': Color(0xFF10B981),
      'phone': '01 23 45 67 90',
      'email': 'bibliotheque@univ-campus.fr',
      'location': 'Bloc B - Rez-de-chaussée',
      'hours': 'Lun-Ven: 8h-22h, Sam: 9h-18h',
      'website': 'biblio.univ-campus.fr',
    },
    {
      'name': 'Examens',
      'description': 'Calendrier des examens, salles, convocations, résultats',
      'icon': Icons.assignment,
      'color': Color(0xFFEF4444),
      'phone': '01 23 45 67 91',
      'email': 'examens@univ-campus.fr',
      'location': 'Bloc A - Étage 2',
      'hours': 'Lun-Ven: 9h-16h',
      'website': 'examens.univ-campus.fr',
    },
    {
      'name': 'Orientation',
      'description': 'Conseil d\'orientation, réorientations, parcours professionnels',
      'icon': Icons.explore,
      'color': Color(0xFFF59E0B),
      'phone': '01 23 45 67 92',
      'email': 'orientation@univ-campus.fr',
      'location': 'Bloc C - Étage 1',
      'hours': 'Lun-Ven: 9h-17h',
      'website': 'orientation.univ-campus.fr',
    },
    {
      'name': 'Informatique',
      'description': 'Support technique, comptes étudiants, salles informatiques',
      'icon': Icons.computer,
      'color': Color(0xFF8B5CF6),
      'phone': '01 23 45 67 93',
      'email': 'support@univ-campus.fr',
      'location': 'Bloc D - Étage 0',
      'hours': 'Lun-Ven: 8h-18h',
      'website': 'support.univ-campus.fr',
    },
    {
      'name': 'Cafétéria',
      'description': 'Restauration, snacks, espace détente, distributeurs',
      'icon': Icons.restaurant,
      'color': Color(0xFF06B6D4),
      'phone': '01 23 45 67 94',
      'email': 'cafeteria@univ-campus.fr',
      'location': 'Bloc E - Rez-de-chaussée',
      'hours': 'Lun-Ven: 7h30-19h',
      'website': null,
    },
    {
      'name': 'Sport',
      'description': 'Inscriptions sportives, équipements, équipes universitaires',
      'icon': Icons.fitness_center,
      'color': Color(0xFF10B981),
      'phone': '01 23 45 67 95',
      'email': 'sport@univ-campus.fr',
      'location': 'Gymnase - Bloc F',
      'hours': 'Lun-Ven: 10h-20h, Sam: 9h-17h',
      'website': 'sport.univ-campus.fr',
    },
    {
      'name': 'Santé',
      'description': 'Service médical, psychologues, infirmerie, urgences',
      'icon': Icons.local_hospital,
      'color': Color(0xFFDC2626),
      'phone': '01 23 45 67 96',
      'email': 'sante@univ-campus.fr',
      'location': 'Bloc G - Étage 0',
      'hours': 'Lun-Ven: 8h-18h (Urgences 24/7)',
      'website': 'sante.univ-campus.fr',
    },
    {
      'name': 'Logement',
      'description': 'Résidences universitaires, appartements, colocations',
      'icon': Icons.home,
      'color': Color(0xFF7C3AED),
      'phone': '01 23 45 67 97',
      'email': 'logement@univ-campus.fr',
      'location': 'Bloc H - Étage 1',
      'hours': 'Lun-Ven: 9h-17h',
      'website': 'logement.univ-campus.fr',
    },
    {
      'name': 'Transport',
      'description': 'Navettes campus, cartes de transport, vélos, parking',
      'icon': Icons.directions_bus,
      'color': Color(0xFF059669),
      'phone': '01 23 45 67 98',
      'email': 'transport@univ-campus.fr',
      'location': 'Bloc I - Extérieur',
      'hours': 'Lun-Ven: 7h-19h',
      'website': null,
    },
    {
      'name': 'Associations',
      'description': 'Clubs étudiants, BDE, associations culturelles et sportives',
      'icon': Icons.groups,
      'color': Color(0xFFEA580C),
      'phone': '01 23 45 67 99',
      'email': 'associations@univ-campus.fr',
      'location': 'Bloc J - Étage 2',
      'hours': 'Lun-Ven: 12h-14h, 17h-19h',
      'website': 'bde.univ-campus.fr',
    },
    {
      'name': 'International',
      'description': 'Échanges, programmes ERASMUS, étudiants étrangers',
      'icon': Icons.public,
      'color': Color(0xFF0891B2),
      'phone': '01 23 45 67 00',
      'email': 'international@univ-campus.fr',
      'location': 'Bloc K - Étage 1',
      'hours': 'Lun-Ven: 9h-16h',
      'website': 'international.univ-campus.fr',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Services du Campus',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const Text(
              '12 services disponibles',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF64748B)),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(context, service);
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    final name = service['name'] as String;
    final description = service['description'] as String;
    final icon = service['icon'] as IconData;
    final color = service['color'] as Color;
    final phone = service['phone'] as String;
    final email = service['email'] as String;
    final location = service['location'] as String;
    final hours = service['hours'] as String;
    final website = service['website'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du service
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Icône du service
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                
                // Nom et description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Informations de contact et localisation
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Localisation
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Localisation',
                  location,
                  color,
                ),
                
                const SizedBox(height: 16),
                
                // Horaires
                _buildInfoRow(
                  Icons.access_time,
                  'Horaires',
                  hours,
                  color,
                ),
                
                const SizedBox(height: 16),
                
                // Contact
                Row(
                  children: [
                    Expanded(
                      child: _buildContactButton(
                        Icons.phone,
                        phone,
                        'Appeler',
                        color,
                        () {
                          _makePhoneCall(phone);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildContactButton(
                        Icons.email,
                        email,
                        'Email',
                        color,
                        () {
                          _sendEmail(email);
                        },
                      ),
                    ),
                  ],
                ),
                
                // Site web (si disponible)
                if (website != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _buildContactButton(
                      Icons.language,
                      website,
                      'Site web',
                      color,
                      () {
                        _openWebsite(website);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton(
    IconData icon,
    String value,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  void _makePhoneCall(String phone) {
    // Implémenter l'appel téléphonique
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appel du $phone...'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _sendEmail(String email) {
    // Implémenter l'envoi d'email
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ouverture du client email pour $email...'),
          backgroundColor: const Color(0xFF2563EB),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openWebsite(String website) {
    // Implémenter l'ouverture du site web
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ouverture de $website...'),
          backgroundColor: const Color(0xFF8B5CF6),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rechercher un service'),
          content: const TextField(
            decoration: InputDecoration(
              hintText: 'Entrez le nom du service...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
