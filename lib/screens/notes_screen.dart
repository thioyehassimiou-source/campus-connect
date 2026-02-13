import 'package:flutter/material.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/shared/models/user.dart';
import 'package:campusconnect/shared/models/pedagogique.dart';

class NotesScreen extends StatefulWidget {
  final User user;

  const NotesScreen({super.key, required this.user});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;
  String _selectedSession = 'Toutes';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    // TODO: Implement with Supabase
    setState(() {
      _isLoading = false;
      // Données de test
      _notes = [
        Note(
          id: '1',
          etudiantId: widget.user.id,
          matiere: 'Mathématiques',
          note: 15.5,
          session: 'Semestre 1',
        ),
        Note(
          id: '2',
          etudiantId: widget.user.id,
          matiere: 'Physique',
          note: 14.0,
          session: 'Semestre 1',
        ),
        Note(
          id: '3',
          etudiantId: widget.user.id,
          matiere: 'Informatique',
          note: 16.5,
          session: 'Semestre 2',
        ),
      ];
    });
  }

  List<Note> get _filteredNotes {
    if (_selectedSession == 'Toutes') return _notes;
    return _notes.where((note) => note.session == _selectedSession).toList();
  }

  double get _moyenneGenerale {
    if (_filteredNotes.isEmpty) return 0.0;
    final sum = _filteredNotes.fold<double>(0.0, (sum, note) => sum + note.note);
    return sum / _filteredNotes.length;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Moyenne générale
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Moyenne Générale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _moyenneGenerale.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Filtre par session
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedSession,
              decoration: const InputDecoration(
                labelText: 'Session',
                border: OutlineInputBorder(),
              ),
              items: ['Toutes', 'Semestre 1', 'Semestre 2']
                  .map((session) => DropdownMenuItem(
                        value: session,
                        child: Text(session),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSession = value!;
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Liste des notes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getNoteColor(note.note),
                      child: Text(
                        note.note.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      note.matiere,
                      style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(note.session),
                    trailing: Text(
                      note.note.toStringAsFixed(1),
                      style: AppTheme.bodyStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getNoteColor(note.note),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getNoteColor(double note) {
    if (note >= 16) return Colors.green;
    if (note >= 14) return Colors.lightGreen;
    if (note >= 12) return Colors.orange;
    if (note >= 10) return Colors.deepOrange;
    return Colors.red;
  }
}
