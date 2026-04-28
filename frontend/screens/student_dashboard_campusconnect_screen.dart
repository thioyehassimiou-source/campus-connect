import 'package:flutter/material.dart';

class StudentDashboardCampusConnectScreen extends StatelessWidget {
  const StudentDashboardCampusConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // Profile Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF136DEC).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF136DEC).withOpacity(0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.account_circle,
                      color: Color(0xFF136DEC),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bonjour, Thomas !',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111418),
                          ),
                        ),
                        Text(
                          'Université de Labé',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF617289),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification Button with Badge
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF111418),
                          size: 20,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emploi du temps Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Emploi du temps',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111418),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF136DEC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Aujourd\'hui',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF136DEC),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Schedule Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'À SUIVRE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF136DEC),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Algorithmique',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111418),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 16, color: Color(0xFF617289)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '10:30 - 12:30',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF617289),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Color(0xFF617289)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Salle B2, Pavillon Central',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF617289),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.arrow_forward, size: 18),
                                  label: const Text('Voir les détails'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF136DEC),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              color: const Color(0xFF136DEC).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF136DEC).withOpacity(0.1),
                              ),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCZwiHhuBerYxCLZbqgLr2GWeM5RG3K-LDdSaYfgIApqSKROpv4BbI4qGbz1_GilgX0JRZkXOp4AQBLG-odaZ7eQOrG1wz0b6RDXKlrqYYa9wQaUSvQu8e3jHI-EFnMIlZ7Kk9cOAlSZtIvVOFd1InfXkCY-VdcB7JyQxfVot1iG_e3ZYUsI6auzKZIryWXB-nZiuOC4BbE0i3H7NYsbTaWbv5vHjvHyVgk1nS2PMOMSohdxma_N_SwjBg7XCVgyw_ESXV0lDFmDdA',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Accès rapide Section
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Text(
                        'Accès rapide',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111418),
                        ),
                      ),
                    ),
                    
                    // Quick Access Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickAccessItem(
                            Icons.calendar_month,
                            'Planning',
                            const Color(0xFFE8F0FE),
                            const Color(0xFF136DEC),
                          ),
                          _buildQuickAccessItem(
                            Icons.description,
                            'Docs',
                            const Color(0xFFFFF4E5),
                            Colors.orange.shade600,
                          ),
                          _buildQuickAccessItem(
                            Icons.grade,
                            'Notes',
                            const Color(0xFFE6F4EA),
                            Colors.green.shade600,
                          ),
                          _buildQuickAccessItem(
                            Icons.apps,
                            'Services',
                            const Color(0xFFF3E5F5),
                            Colors.purple.shade600,
                          ),
                        ],
                      ),
                    ),
                    
                    // Dernières annonces Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Dernières annonces',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111418),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Tout voir',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF136DEC),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // News Carousel
                    SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildNewsCard(
                            'INSCRIPTION',
                            'Inscriptions Ouvertes',
                            'Semestre 2 - Clôture le 15 Mars',
                            const Color(0xFF136DEC),
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBvcy8L5CwmFEZf1cOhgh2MN-1HAtfRB_0EaItpfeHSZtRwQrtPNb3UFXYhqT9DMBbZODhWrovVXgMm8QP40CVaH8Ynh314Res8a425KkwGKWP2eXoy0sp9bhatKHhLb9ZeE5telq0iYKzLr0lOZdEqFPSG4-MuUabDTmkqFjwA2R_4IepQCZv8LKwpCmVBTEfOh99iDOXWC6JTb5S3C9CCoMJODa81VhQpd8EEFiKAF3WDJgSG5WJR92HW2nDTPXa9Ivz_8uhxC_M',
                          ),
                          const SizedBox(width: 16),
                          _buildNewsCard(
                            'SERVICES',
                            'Nouveaux Horaires BU',
                            'Ouvert jusqu\'à 22h cette semaine',
                            Colors.green.shade600,
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCwnCXhu4rB7XYFNdG0lfGTKejL9nJU01jNc-t95xkAsGPuXwU8LsnOSN011v46pGsgzH2lHLhsgnfdmEn5nX__C6qaUf3AxcJWAGE14vRQTY3MRVtaonlEPl2mM0BHv4MxY7TRr7HleI3qqTNwMwH_KdtiPa2tsSaVZIEnLF-y4EplQ15mmeIAoVGNa-C7Xm8TAU2sQeo1zCRV6akRF1Eyq3H7p2FAj_3i0EuBWJMshPl1jsciYYWO2nniE0B9GMbqgPjsXPnpFdI',
                          ),
                          const SizedBox(width: 16),
                          _buildNewsCard(
                            'EXAMEN',
                            'Planning des Partiels',
                            'Session de Juin disponible',
                            Colors.red.shade500,
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCwKFjpWNoEylQzX6CXmxqYXpgJSLysdeIeavB7gYMbLqaji5jZn8VZ_gY9QEQ7m1lgZV49jUI0x5tyTlHeVQjedkVGnh7QX2iVYtpvTZ3vHoiKp1eG48TR6UDY__ptlFPQNv6u5kcWX9QhsC7NJf2JYAAHTgcN1GvTHTMQeakbC3jSrGPfg6KElgvNy20pfeBihJcCpFKXLpF2n20zD2_Tg9PjsDiyerF7oMt3tiYs44N3H2RaNeemihczPA4cHXElSShL-gbhODU',
                          ),
                        ],
                      ),
                    ),
                    
                    // Statistics Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF136DEC),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF136DEC).withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Présence globale',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const Text(
                                '88.5%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 4,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'GOAL',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home, 'Accueil', true),
                _buildNavItem(Icons.campaign, 'Annonces', false),
                _buildNavItem(Icons.school, 'Cours', false),
                _buildNavItem(Icons.person, 'Profil', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String label, Color backgroundColor, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111418),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(String category, String title, String subtitle, Color categoryColor, String imageUrl) {
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111418),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF617289),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: isActive ? const Color(0xFF136DEC) : const Color(0xFF617289),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? const Color(0xFF136DEC) : const Color(0xFF617289),
          ),
        ),
      ],
    );
  }
}