import 'package:flutter/material.dart';

class ModernCampusMapScreen extends StatefulWidget {
  const ModernCampusMapScreen({super.key});

  @override
  State<ModernCampusMapScreen> createState() => _ModernCampusMapScreenState();
}

class _ModernCampusMapScreenState extends State<ModernCampusMapScreen> {

  final List<Map<String, dynamic>> blocs = const [
    {
      'id': 'A',
      'name': 'Bloc A',
      'description': 'Administration & Rectorat',
      'icon': Icons.account_balance,
      'color': Color(0xFF2563EB),
      'services': ['Scolarité', 'Examens', 'Rectorat', 'Direction'],
      'position': Offset(0.2, 0.2),
    },
    {
      'id': 'B',
      'name': 'Bloc B',
      'description': 'Faculté des Sciences',
      'icon': Icons.science,
      'color': Color(0xFF10B981),
      'services': ['Informatique', 'Mathématiques', 'Physique', 'Chimie'],
      'position': Offset(0.7, 0.2),
    },
    {
      'id': 'C',
      'name': 'Bloc C',
      'description': 'Faculté des Lettres & Langues',
      'icon': Icons.menu_book,
      'color': Color(0xFFF59E0B),
      'services': ['Lettres', 'Langues', 'Histoire', 'Philosophie'],
      'position': Offset(0.2, 0.7),
    },
    {
      'id': 'D',
      'name': 'Bloc D',
      'description': 'Bibliothèque & Services',
      'icon': Icons.local_library,
      'color': Color(0xFFEF4444),
      'services': ['Bibliothèque', 'Cafétéria', 'Sport', 'Santé'],
      'position': Offset(0.7, 0.7),
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
              'Carte du Campus',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const Text(
              'Orientation rapide',
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
            icon: const Icon(Icons.info_outline, color: Color(0xFF64748B)),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Carte simplifiée du campus
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Routes principales
                  _buildMainRoads(),
                  
                  // Blocs
                  ...blocs.map((bloc) => _buildBlocCard(context, bloc)),
                  
                  // Entrée principale
                  _buildMainEntrance(),
                  
                  // Parking
                  _buildParking(),
                ],
              ),
            ),
          ),
          
          // Légende claire
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Légende du Campus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: blocs.length,
                      itemBuilder: (context, index) {
                        final bloc = blocs[index];
                        return _buildLegendItem(context, bloc);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainRoads() {
    return Stack(
      children: [
        // Route horizontale principale
        Positioned(
          left: 0,
          right: 0,
          top: 0.45,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        
        // Route verticale principale
        Positioned(
          left: 0.45,
          top: 0,
          bottom: 0,
          child: Container(
            width: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        
        // Allées secondaires
        Positioned(
          left: 0.2,
          right: 0.2,
          top: 0.2,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        Positioned(
          left: 0.2,
          right: 0.2,
          bottom: 0.2,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlocCard(BuildContext context, Map<String, dynamic> bloc) {
    if (!mounted) return Container();
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 40; // Margin de 20 de chaque côté
    final cardSize = containerWidth * 0.2; // 20% de la largeur
    
    return Positioned(
      left: bloc['position'].dx * containerWidth - cardSize / 2,
      top: bloc['position'].dy * containerWidth - cardSize / 2,
      child: GestureDetector(
        onTap: () {
          _showBlocDetails(context, bloc);
        },
        child: Container(
          width: cardSize,
          height: cardSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: bloc['color'],
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                bloc['icon'],
                color: bloc['color'],
                size: cardSize * 0.25,
              ),
              const SizedBox(height: 4),
              Text(
                bloc['id'],
                style: TextStyle(
                  fontSize: cardSize * 0.15,
                  fontWeight: FontWeight.w800,
                  color: bloc['color'],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainEntrance() {
    if (!mounted) return Container();
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 40;
    
    return Positioned(
      left: containerWidth * 0.5 - 30,
      bottom: 10,
      child: Container(
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: const Icon(
          Icons.login,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildParking() {
    if (!mounted) return Container();
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 40;
    
    return Positioned(
      left: containerWidth * 0.85 - 25,
      top: containerWidth * 0.5 - 25,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF64748B).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF64748B),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.local_parking,
          color: Color(0xFF64748B),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Map<String, dynamic> bloc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icône et identifiant
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bloc['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: bloc['color'],
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  bloc['icon'],
                  color: bloc['color'],
                  size: 20,
                ),
                Text(
                  bloc['id'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: bloc['color'],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bloc['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bloc['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: (bloc['services'] as List<String>).take(3).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: bloc['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: bloc['color'],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Flèche
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  void _showBlocDetails(BuildContext context, Map<String, dynamic> bloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(bloc['icon'], color: bloc['color']),
              const SizedBox(width: 8),
              Text('${bloc['name']} - ${bloc['id']}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bloc['description'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Services disponibles :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              ...(bloc['services'] as List<String>).map((service) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    '• $service',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                );
              }).toList(),
            ],
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

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Comment utiliser la carte'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• Cliquez sur un bloc pour voir les détails',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '• Consultez la légende pour connaître les services',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '• Les routes principales sont en gris foncé',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Compris'),
            ),
          ],
        );
      },
    );
  }
}
