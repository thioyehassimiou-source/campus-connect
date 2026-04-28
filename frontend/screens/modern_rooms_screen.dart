import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/core/services/room_service.dart';

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  return await RoomService.getAllRooms();
});

class ModernRoomsScreen extends ConsumerStatefulWidget {
  final bool isTeacher;
  const ModernRoomsScreen({super.key, this.isTeacher = false});

  @override
  ConsumerState<ModernRoomsScreen> createState() => _ModernRoomsScreenState();
}

class _ModernRoomsScreenState extends ConsumerState<ModernRoomsScreen> {
  String _searchQuery = '';
  String? _selectedBloc;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Gestion des Salles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(roomsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres et Recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher une salle...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des Salles
          Expanded(
            child: roomsAsync.when(
              data: (rooms) {
                final filteredRooms = rooms.where((room) {
                  final matchesSearch = room.nom.toLowerCase().contains(_searchQuery) || 
                                       room.bloc.toLowerCase().contains(_searchQuery);
                  final matchesBloc = _selectedBloc == null || room.bloc == _selectedBloc;
                  return matchesSearch && matchesBloc;
                }).toList();

                if (filteredRooms.isEmpty) {
                  return const Center(child: Text('Aucune salle trouvée'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = filteredRooms[index];
                    return _buildRoomTile(room);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: const Color(0xFFF59E0B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRoomTile(Room room) {
    Color statusColor = room.statut == 'Disponible' ? Colors.green : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.meeting_room, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.nom,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${room.bloc} • ${room.capacite} places',
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              room.statut,
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.isTeacher && room.statut == 'Disponible')
            ElevatedButton(
              onPressed: () => _showBookingDialog(room),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Réserver', style: TextStyle(fontSize: 12)),
            )
          else if (!widget.isTeacher)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showEditRoomDialog(room),
            ),
        ],
      ),
    );
  }

  void _showBookingDialog(Room room) {
    final motifController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String debut = '08:00';
    String fin = '10:00';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Réserver la salle ${room.nom}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: motifController,
              decoration: const InputDecoration(labelText: 'Motif (ex: Rattrapage)'),
            ),
            const SizedBox(height: 16),
            // Simplification pour la démo: champs texte pour les heures
            Row(
              children: [
                Expanded(child: Text('Date: ${selectedDate.day}/${selectedDate.month}')),
                TextButton(
                  onPressed: () {}, // Pick date logic
                  child: const Text('Modifier'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                await RoomService.createBooking(
                  roomId: room.id,
                  motif: motifController.text,
                  date: selectedDate,
                  debut: debut,
                  fin: fin,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demande de réservation envoyée !')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: const Text('Envoyer la demande'),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog() {
    final nomController = TextEditingController();
    final blocController = TextEditingController();
    final capaciteController = TextEditingController();
    String selectedType = 'Cours';
    List<String> selectedEquipements = [];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Ajouter une salle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la salle *',
                      hintText: 'Ex: A101',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: blocController,
                    decoration: const InputDecoration(
                      labelText: 'Bloc *',
                      hintText: 'Ex: Bloc A',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: capaciteController,
                    decoration: const InputDecoration(
                      labelText: 'Capacité *',
                      hintText: 'Ex: 50',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Type de salle'),
                    items: ['Cours', 'TP', 'TD', 'Amphithéâtre', 'Labo']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setStateDialog(() => selectedType = value!),
                  ),
                  const SizedBox(height: 16),
                  const Text('Équipements:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: ['Projecteur', 'Tableau', 'Ordinateurs', 'Climatisation'].map((equip) {
                      return FilterChip(
                        label: Text(equip),
                        selected: selectedEquipements.contains(equip),
                        onSelected: (selected) {
                          setStateDialog(() {
                            if (selected) {
                              selectedEquipements.add(equip);
                            } else {
                              selectedEquipements.remove(equip);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nomController.text.isEmpty || blocController.text.isEmpty || capaciteController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                    );
                    return;
                  }
                  
                  try {
                    await RoomService.upsertRoom({
                      'nom': nomController.text,
                      'bloc': blocController.text,
                      'capacite': int.parse(capaciteController.text),
                      'type': selectedType,
                      'equipements': selectedEquipements,
                      'statut': 'Disponible',
                    });
                    
                    ref.invalidate(roomsProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Salle ajoutée avec succès !')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditRoomDialog(Room room) {
    final nomController = TextEditingController(text: room.nom);
    final blocController = TextEditingController(text: room.bloc);
    final capaciteController = TextEditingController(text: room.capacite.toString());
    String selectedType = room.type;
    List<String> selectedEquipements = List.from(room.equipements);
    String selectedStatut = room.statut;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Éditer ${room.nom}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(labelText: 'Nom de la salle'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: blocController,
                    decoration: const InputDecoration(labelText: 'Bloc'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: capaciteController,
                    decoration: const InputDecoration(labelText: 'Capacité'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Type de salle'),
                    items: ['Cours', 'TP', 'TD', 'Amphithéâtre', 'Labo']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setStateDialog(() => selectedType = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatut,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: ['Disponible', 'Occupée', 'Maintenance']
                        .map((stat) => DropdownMenuItem(value: stat, child: Text(stat)))
                        .toList(),
                    onChanged: (value) => setStateDialog(() => selectedStatut = value!),
                  ),
                  const SizedBox(height: 16),
                  const Text('Équipements:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: ['Projecteur', 'Tableau', 'Ordinateurs', 'Climatisation'].map((equip) {
                      return FilterChip(
                        label: Text(equip),
                        selected: selectedEquipements.contains(equip),
                        onSelected: (selected) {
                          setStateDialog(() {
                            if (selected) {
                              selectedEquipements.add(equip);
                            } else {
                              selectedEquipements.remove(equip);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmer la suppression'),
                      content: Text('Voulez-vous vraiment supprimer la salle ${room.nom} ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true) {
                    try {
                      await RoomService.deleteRoom(room.id);
                      ref.invalidate(roomsProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Salle supprimée')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Supprimer'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await RoomService.upsertRoom({
                      'id': room.id,
                      'nom': nomController.text,
                      'bloc': blocController.text,
                      'capacite': int.parse(capaciteController.text),
                      'type': selectedType,
                      'equipements': selectedEquipements,
                      'statut': selectedStatut,
                    });
                    
                    ref.invalidate(roomsProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Salle mise à jour !')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      ),
    );
  }
}
