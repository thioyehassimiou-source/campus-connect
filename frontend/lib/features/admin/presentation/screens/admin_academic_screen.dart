import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/features/admin/data/models/activity_log_model.dart';
import 'package:campusconnect/features/admin/data/services/admin_academic_service.dart';
import 'package:campusconnect/features/admin/presentation/providers/admin_academic_provider.dart';

/// Écran de gestion académique admin (Filières, Cours, Inscriptions).
class AdminAcademicScreen extends ConsumerStatefulWidget {
  const AdminAcademicScreen({super.key});

  @override
  ConsumerState<AdminAcademicScreen> createState() => _AdminAcademicScreenState();
}

class _AdminAcademicScreenState extends ConsumerState<AdminAcademicScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Académique'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.account_tree, size: 18), text: 'Filières'),
            Tab(icon: Icon(Icons.menu_book, size: 18), text: 'Cours'),
            Tab(icon: Icon(Icons.group_add, size: 18), text: 'Inscriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _FilieresTab(),
          _CoursesTab(),
          _InscriptionsTab(),
        ],
      ),
    );
  }
}

// ─── Onglet Filières ──────────────────────────────────────────────────────────

class _FilieresTab extends ConsumerWidget {
  const _FilieresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filieresAsync = ref.watch(filieresProvider);
    final theme = Theme.of(context);

    return filieresAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (filieres) => Scaffold(
        body: filieres.isEmpty
            ? const _EmptyState(icon: Icons.account_tree, label: 'Aucune filière')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filieres.length,
                itemBuilder: (_, i) {
                  final f = filieres[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.account_tree, color: theme.colorScheme.primary, size: 18),
                      ),
                      title: Text(f.nom, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                          '${f.niveau ?? 'N/A'} · Capacité: ${f.capacite ?? '-'}'),
                      trailing: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onSelected: (v) async {
                          if (v == 'delete') {
                            final ok = await _confirmDeletion(context, f.nom);
                            if (ok == true) {
                              await AdminAcademicService.deleteFiliere(f.id);
                              ref.invalidate(filieresProvider);
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'delete',
                              child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Supprimer')])),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateFiliereDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle filière'),
        ),
      ),
    );
  }

  Future<bool?> _confirmDeletion(BuildContext context, String name) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Supprimer la filière ?'),
          content: Text('La filière "$name" sera supprimée.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      );

  Future<void> _showCreateFiliereDialog(BuildContext context, WidgetRef ref) async {
    final nomCtrl = TextEditingController();
    final niveauCtrl = TextEditingController();
    final capaciteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle Filière', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 320,
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom de la filière *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: niveauCtrl,
                decoration: const InputDecoration(labelText: 'Niveau (ex: L1, M2)'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: capaciteCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacité étudiants'),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await AdminAcademicService.createFiliere(FiliereModel(
                id: '',
                nom: nomCtrl.text.trim(),
                niveau: niveauCtrl.text.trim().isEmpty ? null : niveauCtrl.text.trim(),
                capacite: int.tryParse(capaciteCtrl.text),
              ));
              ref.invalidate(filieresProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}

// ─── Onglet Cours ─────────────────────────────────────────────────────────────

class _CoursesTab extends ConsumerWidget {
  const _CoursesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesAdminProvider);
    final teachersAsync = ref.watch(teachersListProvider);
    final theme = Theme.of(context);

    return coursesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (courses) => Scaffold(
        body: courses.isEmpty
            ? const _EmptyState(icon: Icons.menu_book, label: 'Aucun cours')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: courses.length,
                itemBuilder: (_, i) {
                  final c = courses[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        child: Text(
                          c.code != null && c.code!.isNotEmpty ? c.code![0] : 'C',
                          style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w800),
                        ),
                      ),
                      title: Text(c.nom, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(c.teacherName ?? 'Enseignant non assigné'),
                      trailing: teachersAsync.maybeWhen(
                        data: (teachers) => IconButton(
                          icon: const Icon(Icons.person_pin, size: 20),
                          tooltip: 'Assigner enseignant',
                          onPressed: () => _showAssignTeacherDialog(context, ref, c, teachers),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateCourseDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Nouveau cours'),
        ),
      ),
    );
  }

  Future<void> _showAssignTeacherDialog(BuildContext context, WidgetRef ref,
      CourseAdminModel course, List<Map<String, String>> teachers) async {
    String? selectedId = course.teacherId;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assigner à "${course.nom}"'),
          content: DropdownButtonFormField<String>(
            value: teachers.any((t) => t['id'] == selectedId) ? selectedId : null,
            hint: const Text('Sélectionner un enseignant'),
            items: teachers.map((t) =>
                DropdownMenuItem(value: t['id'], child: Text(t['name'] ?? ''))).toList(),
            onChanged: (v) => setState(() => selectedId = v),
            decoration: const InputDecoration(labelText: 'Enseignant'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(
              onPressed: selectedId == null ? null : () async {
                await AdminAcademicService.assignTeacherToCourse(course.id, selectedId!);
                ref.invalidate(coursesAdminProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Assigner'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateCourseDialog(BuildContext context, WidgetRef ref) async {
    final nomCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau Cours', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 320,
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom du cours *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Code cours (ex: INF301)'),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await AdminAcademicService.createCourse(CourseAdminModel(
                id: '',
                nom: nomCtrl.text.trim(),
                code: codeCtrl.text.trim().isEmpty ? null : codeCtrl.text.trim(),
              ));
              ref.invalidate(coursesAdminProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}

// ─── Onglet Inscriptions ──────────────────────────────────────────────────────

class _InscriptionsTab extends ConsumerWidget {
  const _InscriptionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filieresAsync = ref.watch(filieresProvider);
    return filieresAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (filieres) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.group_add, size: 48, color: Color(0xFF3B82F6)),
              const SizedBox(height: 12),
              Text('${filieres.length} filières disponibles',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('L\'inscription des étudiants se fait depuis le profil utilisateur.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.people),
                label: const Text('Voir les étudiants'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
}
