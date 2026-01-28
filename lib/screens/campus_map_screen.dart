import 'package:flutter/material.dart';

class CampusMapScreen extends StatelessWidget {
  const CampusMapScreen({super.key});

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
        title: const Text(
          'Carte du Campus',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une salle ou un département',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Carte du campus
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Route centrale
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 100,
                    child: Container(
                      height: 60,
                      color: const Color(0xFFCBD5E1),
                    ),
                  ),
                  
                  // Bloc A
                  Positioned(
                    left: 40,
                    top: 40,
                    child: _buildBlocCard('Bloc A', const Color(0xFF2563EB), Icons.account_balance),
                  ),
                  
                  // Bloc B
                  Positioned(
                    right: 40,
                    top: 40,
                    child: _buildBlocCard('Bloc B', const Color(0xFF10B981), Icons.science),
                  ),
                  
                  // Bloc C
                  Positioned(
                    left: 40,
                    bottom: 40,
                    child: _buildBlocCard('Bloc C', const Color(0xFFF59E0B), Icons.menu_book),
                  ),
                  
                  // Bloc D
                  Positioned(
                    right: 40,
                    bottom: 40,
                    child: _buildBlocCard('Bloc D', const Color(0xFFEF4444), Icons.local_library),
                  ),
                  
                  // Boutons de contrôle
                  Positioned(
                    right: 20,
                    top: 200,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          onPressed: () {},
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.add, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton.small(
                          onPressed: () {},
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.remove, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ),
                  
                  // Bouton localisation
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: const Color(0xFF2563EB),
                      child: const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Légende
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Légende du Campus',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegendItem('Bloc A', 'Administration & Rectorat', Icons.account_balance, const Color(0xFF2563EB)),
                _buildLegendItem('Bloc B', 'Faculté des Sciences', Icons.science, const Color(0xFF10B981)),
                _buildLegendItem('Bloc C', 'Faculté des Lettres & Langues', Icons.menu_book, const Color(0xFFF59E0B)),
                _buildLegendItem('Bloc D', 'Bibliothèque & Cafétéria', Icons.local_library, const Color(0xFFEF4444)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF64748B),
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Emploi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Actualités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildBlocCard(String title, Color color, IconData icon) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}