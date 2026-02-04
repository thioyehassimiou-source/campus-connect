import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModernServicesScreen extends StatefulWidget {
  const ModernServicesScreen({super.key});

  @override
  State<ModernServicesScreen> createState() => _ModernServicesScreenState();
}

class _ModernServicesScreenState extends State<ModernServicesScreen> {

  bool _isLoading = true;
  List<Map<String, dynamic>> services = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final response = await Supabase.instance.client
          .from('services')
          .select()
          .order('nom', ascending: true);

      setState(() {
        services = List<Map<String, dynamic>>.from(response).map((data) {
          return {
            'name': data['nom'] ?? 'Service',
            'description': data['description'] ?? 'Service disponible sur le campus',
            'icon': _getIconForService(data['nom'] ?? ''),
            'color': _getColorForService(data['nom'] ?? ''),
            'phone': data['telephone'] ?? 'Non renseigné',
            'email': data['email'] ?? 'Non renseigné',
            'location': data['localisation'] ?? data['location'] ?? 'Campus',
            'hours': data['horaires'] ?? 'Lun-Ven: 8h-17h',
            'website': data['site_web'] ?? data['website'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur chargement services: $e');
      setState(() {
        _errorMessage = 'Impossible de charger les services';
        _isLoading = false;
      });
    }
  }

  IconData _getIconForService(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('bibli')) return Icons.library_books;
    if (lower.contains('scolar')) return Icons.school;
    if (lower.contains('exam')) return Icons.assignment;
    if (lower.contains('sport')) return Icons.fitness_center;
    if (lower.contains('sant')) return Icons.local_hospital;
    if (lower.contains('informatique') || lower.contains('numerique')) return Icons.computer;
    if (lower.contains('logement')) return Icons.home;
    if (lower.contains('transport')) return Icons.directions_bus;
    if (lower.contains('resto') || lower.contains('cafe')) return Icons.restaurant;
    if (lower.contains('bde') || lower.contains('assoc')) return Icons.groups;
    if (lower.contains('inter')) return Icons.public;
    return Icons.business; 
  }

  Color _getColorForService(String name) {
    final colors = [
      const Color(0xFF2563EB), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFEF4444), // Red
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEA580C), // Dark Orange
      const Color(0xFF7C3AED), // Violet
      const Color(0xFF059669), // Emerald
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services du Campus',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              _isLoading ? 'Chargement...' : '${services.length} services disponibles',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      TextButton(
                        onPressed: _fetchServices,
                        child: Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : services.isEmpty
                  ? const Center(child: Text('Aucun service trouvé'))
                  : ListView.builder(
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor,
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
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
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
          title: Text('Rechercher un service'),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'Entrez le nom du service...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
