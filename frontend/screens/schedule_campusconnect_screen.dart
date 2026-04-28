import 'package:flutter/material.dart';

class ScheduleCampusConnectScreen extends StatelessWidget {
  const ScheduleCampusConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF136DEC).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_month,
                                color: Color(0xFF136DEC),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Emploi du temps',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111418),
                                  ),
                                ),
                                Text(
                                  'Semestre 2 • Campus Centre',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF617289),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF136DEC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Aujourd\'hui',
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
                  
                  // Date Tabs
                  Container(
                    height: 80,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildDateTab('Lun', '12', false),
                        const SizedBox(width: 12),
                        _buildDateTab('Mar', '13', true),
                        const SizedBox(width: 12),
                        _buildDateTab('Mer', '14', false),
                        const SizedBox(width: 12),
                        _buildDateTab('Jeu', '15', false),
                        const SizedBox(width: 12),
                        _buildDateTab('Ven', '16', false),
                        const SizedBox(width: 12),
                        _buildDateTab('Sam', '17', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Current Time Indicator
                    _buildTimeIndicator('10:45'),
                    
                    const SizedBox(height: 16),
                    
                    // Finished Class
                    _buildClassCard(
                      'Algorithmique Avancée',
                      'LECTURE (CM)',
                      '08:00 - 10:00',
                      'Amphithéâtre B • Bâtiment Colbert',
                      'Pr. Jean Dupont',
                      const Color(0xFF2E7D32),
                      isFinished: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Active Class
                    _buildClassCard(
                      'Systèmes d\'exploitation',
                      'TUTORIAL (TD)',
                      '10:15 - 12:15',
                      'Salle 204',
                      'Pr. Marie Curie',
                      const Color(0xFF136DEC),
                      isActive: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Lunch Break
                    _buildBreakIndicator('PAUSE DÉJEUNER'),
                    
                    const SizedBox(height: 16),
                    
                    // Upcoming Classes
                    _buildClassCard(
                      'Base de données',
                      'LAB (TP)',
                      '14:00 - 16:00',
                      'Labo Informatique 3',
                      'Dr. Alan Turing',
                      const Color(0xFF7B1FA2),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildClassCard(
                      'Anglais Technique',
                      'TUTORIAL (TD)',
                      '16:15 - 18:15',
                      'Salle 102',
                      'Mme. Sarah Connor',
                      const Color(0xFF136DEC),
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
          color: Colors.white.withOpacity(0.8),
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.calendar_today, 'Planning', true),
                    _buildNavItem(Icons.school, 'Cours', false),
                    _buildNavItem(Icons.grade, 'Notes', false),
                    _buildNavItem(Icons.person, 'Profil', false),
                  ],
                ),
              ),
              // iOS Home Indicator
              Container(
                width: 128,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTab(String day, String date, bool isSelected) {
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF136DEC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: const Color(0xFF136DEC).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF617289),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF111418),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeIndicator(String time) {
    return Row(
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF136DEC),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFF136DEC),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF136DEC),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildClassCard(
    String title,
    String type,
    String time,
    String location,
    String instructor,
    Color accentColor, {
    bool isFinished = false,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isFinished ? Colors.white.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF136DEC) : const Color(0xFFE5E7EB),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive 
                ? const Color(0xFF136DEC).withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            blurRadius: isActive ? 12 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left Color Bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(isActive ? 20 : 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: isActive ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111418),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive ? accentColor : accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : accentColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (isActive)
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(Icons.schedule, time, isActive),
                            ),
                            Expanded(
                              child: _buildInfoRow(Icons.location_on, location, false),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildInfoRow(Icons.schedule, time, false),
                            const SizedBox(height: 4),
                            _buildInfoRow(Icons.location_on, location, false),
                            const SizedBox(height: 4),
                            _buildInfoRow(Icons.person, instructor, false),
                          ],
                        ),
                      if (isActive) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.person, instructor, false),
                      ],
                    ],
                  ),
                ),
                if (isFinished)
                  Icon(
                    Icons.check_circle,
                    color: accentColor,
                    size: 24,
                  )
                else if (isActive)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'EN COURS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF136DEC),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isHighlighted) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isHighlighted ? const Color(0xFF136DEC) : const Color(0xFF617289),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
              color: isHighlighted ? const Color(0xFF111418) : const Color(0xFF617289),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakIndicator(String label) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF617289),
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 26,
          color: isActive ? const Color(0xFF136DEC) : const Color(0xFF617289),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isActive ? const Color(0xFF136DEC) : const Color(0xFF617289),
          ),
        ),
      ],
    );
  }
}