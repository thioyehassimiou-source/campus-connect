import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/documents_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/document.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  late final DocumentsService _service;

  List<String> _filieres = const [];
  String? _selectedFiliere;

  bool _loadingFilieres = true;
  bool _loadingDocs = false;

  List<PedagogicDocument> _docs = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = DocumentsService(Supabase.instance.client);
    _loadFilieres();
  }

  Future<void> _loadFilieres() async {
    setState(() {
      _loadingFilieres = true;
      _error = null;
    });

    try {
      final filieres = await _service.fetchFilieres();
      setState(() {
        _filieres = filieres;
        _selectedFiliere = filieres.isNotEmpty ? filieres.first : null;
        _loadingFilieres = false;
      });

      if (_selectedFiliere != null) {
        await _loadDocs();
      }
    } catch (e) {
      setState(() {
        _loadingFilieres = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadDocs() async {
    final filiere = _selectedFiliere;
    if (filiere == null) return;

    setState(() {
      _loadingDocs = true;
      _error = null;
    });

    try {
      final docs = await _service.fetchByFiliere(filiere: filiere);
      final user = ref.read(authProvider).user;
      
      // Filter by role
      final filtered = user == null
          ? <PedagogicDocument>[]
          : docs.where((d) => d.canBeSeenBy(user.role)).toList();

      setState(() {
        _docs = filtered;
        _loadingDocs = false;
      });
    } catch (e) {
      setState(() {
        _loadingDocs = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: (_loadingFilieres || _loadingDocs) ? null : _loadDocs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFiliereFilter(),
            const SizedBox(height: 12),
            if (_loadingFilieres || _loadingDocs)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_docs.isEmpty)
              const Expanded(
                child: Center(child: Text('Aucun document trouvé pour cette filière.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _docs.length,
                  itemBuilder: (context, index) {
                    final doc = _docs[index];
                    final canDownload = user != null && _service.canDownload(user, doc);
                    return _DocumentTile(
                      doc: doc,
                      canDownload: canDownload,
                      onDownload: () => _handleDownload(user: user, doc: doc),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiliereFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            'Filière',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedFiliere,
                hint: const Text('Choisir une filière'),
                items: _filieres
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(f),
                      ),
                    )
                    .toList(),
                onChanged: _loadingFilieres
                    ? null
                    : (value) async {
                        setState(() {
                          _selectedFiliere = value;
                        });
                        await _loadDocs();
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownload({
    required dynamic user,
    required PedagogicDocument doc,
  }) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter.')),
      );
      return;
    }

    if (!_service.canDownload(user, doc)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accès refusé.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final url = await _service.resolveDownloadUrl(doc: doc);
      await _service.copyToClipboard(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lien copié dans le presse-papiers (prototype).'),
          ),
        );
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
    }
  }
}

class _DocumentTile extends StatelessWidget {
  final PedagogicDocument doc;
  final bool canDownload;
  final VoidCallback onDownload;

  const _DocumentTile({
    required this.doc,
    required this.canDownload,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (doc.description != null && doc.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    doc.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey.shade700),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Chip(text: doc.target.label, color: Colors.blue),
                    const SizedBox(width: 8),
                    _Chip(
                      text: doc.isPublic ? 'Public' : 'Privé',
                      color: doc.isPublic ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: canDownload ? onDownload : null,
            icon: Icon(
              Icons.download,
              color: canDownload ? Colors.blue : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;

  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
