import 'package:flutter/material.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/shared/models/user.dart';
import 'package:campusconnect/shared/models/pedagogique.dart';

class EmploiDuTempsScreen extends StatefulWidget {
  final User user;

  const EmploiDuTempsScreen({super.key, required this.user});

  @override
  State<EmploiDuTempsScreen> createState() => _EmploiDuTempsScreenState();
}

class _EmploiDuTempsScreenState extends State<EmploiDuTempsScreen> {
  List<EmploiDuTemps> _emploiDuTemps = [];
  bool _isLoading = true;

  final List<String> _jours = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'
  ];

  @override
  void initState() {
    super.initState();
    _loadEmploiDuTemps();
  }

  Future<void> _loadEmploiDuTemps() async {
    // TODO: Implement with Supabase
    setState(() {
      _isLoading = false;
      // Données de test
      _emploiDuTemps = [
        EmploiDuTemps(
          id: '1',
          filiereId: '1',
          salleId: '1',
          enseignantId: '1',
          jour: 'Lundi',
          heureDebut: '08:00',
          heureFin: '10:00',
          matiere: 'Mathématiques',
        ),
        EmploiDuTemps(
          id: '2',
          filiereId: '1',
          salleId: '2',
          enseignantId: '2',
          jour: 'Lundi',
          heureDebut: '10:15',
          heureFin: '12:15',
          matiere: 'Physique',
        ),
      ];
    });
  }

  Map<String, List<EmploiDuTemps>> _groupEmploiDuTempsByDay() {
    Map<String, List<EmploiDuTemps>> grouped = {};
    for (var jour in _jours) {
      grouped[jour] = [];
    }
    
    for (var cours in _emploiDuTemps) {
      if (grouped.containsKey(cours.jour)) {
        grouped[cours.jour]!.add(cours);
      }
    }
    
    // Trier par heure de début
    for (var jour in grouped.keys) {
      grouped[jour]!.sort((a, b) => a.heureDebut.compareTo(b.heureDebut));
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final groupedCours = _groupEmploiDuTempsByDay();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emploi du temps'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _jours.length,
        itemBuilder: (context, index) {
          final jour = _jours[index];
          final coursDuJour = groupedCours[jour] ?? [];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ExpansionTile(
              title: Text(
                jour,
                style: AppTheme.headingStyle.copyWith(fontSize: 18),
              ),
              subtitle: Text('${coursDuJour.length} cours'),
              children: coursDuJour.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Aucun cours ce jour'),
                      )
                    ]
                  : coursDuJour.map((cours) => _buildCoursTile(cours)).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoursTile(EmploiDuTemps cours) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.book,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        cours.matiere,
        style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${cours.heureDebut} - ${cours.heureFin}',
        style: AppTheme.bodyStyle.copyWith(color: Colors.grey),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Salle ${cours.salleId}',
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Enseignant ${cours.enseignantId}',
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
