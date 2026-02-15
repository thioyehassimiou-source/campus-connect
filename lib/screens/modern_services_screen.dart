import 'package:flutter/material.dart';
import 'package:campusconnect/core/services/campus_service.dart';
import 'package:campusconnect/models/institutional_service.dart';
import 'package:campusconnect/shared/widgets/campus_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:campusconnect/screens/modern_service_detail_screen.dart';

class ModernServicesScreen extends StatefulWidget {
  const ModernServicesScreen({super.key});

  @override
  State<ModernServicesScreen> createState() => _ModernServicesScreenState();
}

class _ModernServicesScreenState extends State<ModernServicesScreen> {
  bool _isLoading = true;
  List<InstitutionalService> _allServices = [];
  Map<String, List<InstitutionalService>> _groupedServices = {};
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  // Assistant IA (Simulé comme un service)
  final InstitutionalService _aiAssistant = InstitutionalService(
    id: 'ai-assistant',
    nom: 'Assistant IA Académique',
    description: 'Votre assistant intelligent pour toutes vos questions universitaires.',
    category: ServiceCategory.OTHER, // Special handling
    isActive: true,
    email: 'Assistant Virtuel',
    telephone: '24/7',
    localisation: 'Application',
  );

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final services = await CampusService.getInstitutionalServices();
      
      // Deduplicate services based on lowercase name
      final uniqueServices = <String, InstitutionalService>{};
      for (var s in services) {
        final key = s.nom.toLowerCase().trim();
        if (!uniqueServices.containsKey(key)) {
          uniqueServices[key] = s;
        } else {
          // If we have a duplicate, keep the one with more info (e.g. description) or just first one
          // Here we just keep the first one found, assuming newer ones come first or last depending on sort
          // Ideally, we'd pick the "best" one. For now, first wins.
        }
      }
      
      setState(() {
        _allServices = uniqueServices.values.toList();
        _groupServices(_allServices);
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

  void _groupServices(List<InstitutionalService> services) {
    final Map<String, List<InstitutionalService>> grouped = {};

    // 1. Assistant IA (Toujours en premier si pas de recherche)
    if (_searchController.text.isEmpty) {
       grouped['Assistant Intelligent'] = [_aiAssistant];
    }

    // 2. Gouvernance
    final gouv = services.where((s) => s.category == ServiceCategory.GOVERNANCE).toList();
    if (gouv.isNotEmpty) grouped['Gouvernance & Direction'] = gouv;

    // 3. Administration
    final admin = services.where((s) => s.category == ServiceCategory.ADMIN).toList();
    if (admin.isNotEmpty) grouped['Administration Centrale'] = admin;

    // 4. Académique
     final academic = services.where((s) => s.category == ServiceCategory.ACADEMIC).toList();
    if (academic.isNotEmpty) grouped['Services Académiques'] = academic;

    // 5. Support
    final support = services.where((s) => s.category == ServiceCategory.SUPPORT).toList();
    if (support.isNotEmpty) grouped['Appui & Ressources'] = support;

    // 6. Autres
    final other = services.where((s) => s.category == ServiceCategory.OTHER).toList();
    if (other.isNotEmpty) grouped['Autres Services'] = other;

    _groupedServices = grouped;
  }

  void _filterServices(String query) {
    setState(() {
      if (query.isEmpty) {
        _groupServices(_allServices);
      } else {
        final filteredIds = _allServices.where((s) {
          final name = s.nom.toLowerCase();
          final desc = (s.description ?? '').toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q) || desc.contains(q);
        }).toList();
        
        // On regroupe uniquement les résultats filtrés
        _groupServices(filteredIds);
        
        // Si l'assistant matche aussi
        if ('assistant ia académique'.contains(query.toLowerCase())) {
           // Déjà géré par _groupServices si on veut, mais ici on simplifie
           // L'assistant est ajouté manuellement dans _groupServices si search vide,
           // sinon on l'ajoute ici si match
           if (_groupedServices.containsKey('Assistant Intelligent')) {
             // keep it
           } else {
              _groupedServices = {
                'Résultats': [_aiAssistant, ...filteredIds]
              };
           }
        }
      }
    });
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
              'Services du Campus (V2)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
               _isLoading ? 'Chargement...' : '${_allServices.length} services répertoriés',
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
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            onPressed: _fetchServices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchField(),
                Expanded(
                  child: _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(_errorMessage!),
                              TextButton(
                                onPressed: _fetchServices,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _groupedServices.isEmpty
                          ? const Center(child: Text('Aucun service trouvé'))
                          : ListView.builder(
                              itemCount: _groupedServices.length,
                              itemBuilder: (context, index) {
                                final categoryName = _groupedServices.keys.elementAt(index);
                                final services = _groupedServices[categoryName]!;

                                return StickyHeader(
                                  header: Container(
                                    height: 50.0,
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      categoryName.toUpperCase(),
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  content: Column(
                                    children: services.map((service) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: _buildServiceCard(context, service),
                                    )).toList(),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterServices,
        decoration: InputDecoration(
          hintText: 'Rechercher un service...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, InstitutionalService service) {
    final bool isAi = service.id == 'ai-assistant';
    final name = service.nom;
    final description = service.description ?? '';
    final color = _getColorForCategory(service.category, isAi);
    final icon = _getIconForService(service.nom, service.category, isAi);
    
    // DEBUG: Print service details to verify SQL update
    if (service.nom.toLowerCase().contains('scolarité') || service.nom.toLowerCase().contains('médical')) {
      print('DEBUG SERVICE [${service.nom}]: Loc: ${service.localisation}, Phone: ${service.telephone}, Email: ${service.email}');
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),

      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModernServiceDetailScreen(service: service),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                   ),
                   if (!isAi) ...[
                     const SizedBox(height: 16),
                     Row(
                        children: [
                          if (service.telephone != null)
                             Padding(
                               padding: const EdgeInsets.only(right: 8),
                               child: Icon(Icons.phone, size: 16, color: color),
                             ),
                          if (service.email != null)
                             Padding(
                               padding: const EdgeInsets.only(right: 8),
                               child: Icon(Icons.email, size: 16, color: color),
                             ),
                          if (service.localisation != null)
                             Icon(Icons.location_on, size: 16, color: color),
                             
                          const Spacer(),
                          Text(
                            "Voir l'espace",
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                     ),
                   ],
                   if (isAi) ...[
                      const SizedBox(height: 16),
                       SizedBox(
                        width: double.infinity,
                        child: CampusButton.primary(
                          text: "Lancer l'Assistant",
                          icon: Icons.chat_bubble_outline,
                          onPressed: () {
                            Navigator.pushNamed(context, '/ai-assistant');
                          },
                        ),
                      )
                   ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

   Color _getColorForCategory(ServiceCategory category, bool isAi) {
     if (isAi) return const Color(0xFF6366F1); // Indigo
     switch (category) {
       case ServiceCategory.GOVERNANCE: return const Color(0xFF2563EB); // Blue
       case ServiceCategory.ADMIN: return const Color(0xFF059669); // Emerald
       case ServiceCategory.ACADEMIC: return const Color(0xFFEA580C); // Orange
       case ServiceCategory.SUPPORT: return const Color(0xFF7C3AED); // Violet
       default: return Colors.grey;
     }
  }

  IconData _getIconForService(String name, ServiceCategory category, bool isAi) {
    if (isAi) return Icons.psychology_outlined;
    
    // Icone par défaut selon catégorie
    switch (category) {
       case ServiceCategory.GOVERNANCE: 
         if (name.contains('Rectorat')) return Icons.account_balance;
         return Icons.gavel;
       case ServiceCategory.ADMIN:
         if (name.contains('Santé') || name.contains('Médical')) return Icons.local_hospital;
         if (name.contains('Scolarité')) return Icons.school;
         if (name.contains('Finance') || name.contains('Comptable')) return Icons.attach_money;
         if (name.contains('Sécurité') || name.contains('Ordre')) return Icons.security;
         return Icons.admin_panel_settings;
       case ServiceCategory.ACADEMIC:
         if (name.contains('Recherche')) return Icons.science;
         return Icons.menu_book;
       case ServiceCategory.SUPPORT:
         if (name.contains('Bibliothèque')) return Icons.local_library;
         if (name.contains('Informatique')) return Icons.computer;
         if (name.contains('Sport')) return Icons.sports_basketball;
         return Icons.support;
       default: return Icons.business;
    }
  }

   Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
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
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ... (keep _makePhoneCall, _sendEmail, _openWebsite same as before but adapted if needed)
  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (!await launchUrl(launchUri)) throw Exception('Erreur');
    } catch (_) {}
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    try {
      if (!await launchUrl(launchUri)) throw Exception('Erreur');
    } catch (_) {}
  }
}
