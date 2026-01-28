import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/documents_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/document.dart';

class TeacherPublishDocumentScreen extends ConsumerStatefulWidget {
  const TeacherPublishDocumentScreen({super.key});

  @override
  ConsumerState<TeacherPublishDocumentScreen> createState() =>
      _TeacherPublishDocumentScreenState();
}

class _TeacherPublishDocumentScreenState
    extends ConsumerState<TeacherPublishDocumentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fileUrlController = TextEditingController();
  final _filiereController = TextEditingController();

  DocumentTarget _target = DocumentTarget.etudiants;
  bool _isPublic = false;

  bool _loading = false;
  List<String> _filieres = const [];

  late final DocumentsService _service;

  @override
  void initState() {
    super.initState();
    _service = DocumentsService(Supabase.instance.client);
    _loadFilieres();
  }

  Future<void> _loadFilieres() async {
    try {
      final filieres = await _service.fetchFilieres();
      if (!mounted) return;
      setState(() {
        _filieres = filieres;
      });
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fileUrlController.dispose();
    _filiereController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté.')),
      );
    }

    if (!_service.canPublish(user.role)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Publier un document'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Accès refusé : réservé aux enseignants et admins.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Publier un document'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Titre requis';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FiliereField(
                      filieres: _filieres,
                      controller: _filiereController,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fileUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL du fichier (prototype)',
                        hintText: 'https://.../document.pdf',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'URL requise (prototype)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<DocumentTarget>(
                      value: _target,
                      decoration: const InputDecoration(
                        labelText: 'Ciblage',
                        border: OutlineInputBorder(),
                      ),
                      items: DocumentTarget.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ),
                          )
                          .toList(),
                      onChanged: _loading
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _target = value);
                            },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: _isPublic,
                      onChanged: _loading ? null : (v) => setState(() => _isPublic = v),
                      title: const Text('Public'),
                      subtitle: const Text('Si activé, visible par tous les rôles'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loading ? null : () => _submit(userId: user.id),
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload),
                label: const Text('Publier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit({required String userId}) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _service.publishDocument(
        author: user,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        filiere: _filiereController.text.trim(),
        fileUrl: _fileUrlController.text.trim(),
        isPublic: _isPublic,
        target: _target,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document publié.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _FiliereField extends StatelessWidget {
  final List<String> filieres;
  final TextEditingController controller;

  const _FiliereField({required this.filieres, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (filieres.isEmpty) {
      return TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Filière',
          border: OutlineInputBorder(),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Filière requise';
          return null;
        },
      );
    }

    if (controller.text.isEmpty) {
      controller.text = filieres.first;
    }

    return DropdownButtonFormField<String>(
      value: controller.text,
      decoration: const InputDecoration(
        labelText: 'Filière',
        border: OutlineInputBorder(),
      ),
      items: filieres
          .map(
            (f) => DropdownMenuItem(
              value: f,
              child: Text(f),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        controller.text = v;
      },
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Filière requise';
        return null;
      },
    );
  }
}
