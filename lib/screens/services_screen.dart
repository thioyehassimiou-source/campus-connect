import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/models/user_model.dart';

class ServicesScreen extends StatefulWidget {
  final UserModel user;

  const ServicesScreen({super.key, required this.user});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final List<ServiceItem> _services = [
    ServiceItem(
      title: 'Bibliothèque',
      description: 'Accès aux ressources documentaires',
      icon: Icons.menu_book,
      color: AppTheme.primaryColor,
      phone: '+221 33 123 45 67',
      email: 'bibliotheque@campus.edu',
      location: 'Bâtiment A, 1er étage',
    ),
    ServiceItem(
      title: 'Scolarité',
      description: 'Gestion administrative des études',
      icon: Icons.school,
      color: AppTheme.successColor,
      phone: '+221 33 234 56 78',
      email: 'scolarite@campus.edu',
      location: 'Bâtiment B, rez-de-chaussée',
    ),
    ServiceItem(
      title: 'Informatique',
      description: 'Support technique et accès aux salles',
      icon: Icons.computer,
      color: AppTheme.warningColor,
      phone: '+221 33 345 67 89',
      email: 'it@campus.edu',
      location: 'Bâtiment C, 2ème étage',
    ),
    ServiceItem(
      title: 'Cafétéria',
      description: 'Restauration et services alimentaires',
      icon: Icons.restaurant,
      color: Colors.orange,
      phone: '+221 33 456 78 90',
      email: 'cafeteria@campus.edu',
      location: 'Bâtiment D',
    ),
    ServiceItem(
      title: 'Sports',
      description: 'Installations sportives et activités',
      icon: Icons.sports_soccer,
      color: Colors.green,
      phone: '+221 33 567 89 01',
      email: 'sports@campus.edu',
      location: 'Complexe sportif',
    ),
    ServiceItem(
      title: 'Santé',
      description: 'Services médicaux et psychologiques',
      icon: Icons.local_hospital,
      color: AppTheme.errorColor,
      phone: '+221 33 678 90 12',
      email: 'sante@campus.edu',
      location: 'Bâtiment E',
    ),
    ServiceItem(
      title: 'Logement',
      description: 'Résidences universitaires',
      icon: Icons.home,
      color: Colors.purple,
      phone: '+221 33 789 01 23',
      email: 'logement@campus.edu',
      location: 'Campus Nord',
    ),
    ServiceItem(
      title: 'Transport',
      description: 'Navettes et parking',
      icon: Icons.directions_bus,
      color: Colors.teal,
      phone: '+221 33 890 12 34',
      email: 'transport@campus.edu',
      location: 'Portail principal',
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Campus'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un service...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Services Grid
          Expanded(
            child: _filteredServices.isEmpty
                ? const Center(
                    child: Text('Aucun service trouvé'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      return _buildServiceCard(service);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<ServiceItem> get _filteredServices {
    if (_searchQuery.isEmpty) return _services;

    return _services.where((service) {
      final title = service.title.toLowerCase();
      final description = service.description.toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) ||
             description.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildServiceCard(ServiceItem service) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showServiceDetails(service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: service.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  service.icon,
                  size: 32,
                  color: service.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service.title,
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                service.description,
                style: AppTheme.captionStyle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceDetails(ServiceItem service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Service Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: service.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      service.icon,
                      size: 32,
                      color: service.color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: AppTheme.subheadingStyle,
                        ),
                        Text(
                          service.description,
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Contact Information
              Text(
                'Contact',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 16),

              // Phone
              _buildContactTile(
                icon: Icons.phone,
                title: 'Téléphone',
                value: service.phone,
                onTap: () => _launchPhone(service.phone),
              ),

              // Email
              _buildContactTile(
                icon: Icons.email,
                title: 'Email',
                value: service.email,
                onTap: () => _launchEmail(service.email),
              ),

              // Location
              _buildContactTile(
                icon: Icons.location_on,
                title: 'Localisation',
                value: service.location,
                onTap: () => _launchMaps(service.location),
              ),

              const SizedBox(height: 24),

              // Actions
              Text(
                'Actions rapides',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchPhone(service.phone),
                      icon: const Icon(Icons.phone),
                      label: const Text('Appeler'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: service.color,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchEmail(service.email),
                      icon: const Icon(Icons.email),
                      label: const Text('Email'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: service.color,
                        side: BorderSide(color: service.color),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _launchMaps(service.location),
                  icon: const Icon(Icons.map),
                  label: const Text('Voir sur la carte'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: service.color,
                    side: BorderSide(color: service.color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'appeler $phoneNumber')),
      );
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Contact depuis CampusConnect',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'envoyer un email à $email')),
      );
    }
  }

  Future<void> _launchMaps(String location) async {
    final Uri mapsUri = Uri(
      scheme: 'https',
      host: 'maps.google.com',
      queryParameters: {'q': location},
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir la carte pour $location')),
      );
    }
  }
}

class ServiceItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String phone;
  final String email;
  final String location;

  ServiceItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.phone,
    required this.email,
    required this.location,
  });
}
