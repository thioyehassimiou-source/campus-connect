import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/features/admin/data/models/admin_user_model.dart';
import 'package:campusconnect/features/admin/data/services/admin_service_v2.dart';
import 'package:campusconnect/features/admin/presentation/providers/admin_users_provider.dart';
import 'package:campusconnect/shared/models/user_model.dart';

/// Écran de gestion des utilisateurs — liste paginée, filtres, CRUD complet.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _selectedRole;

  static const _roles = ['Étudiant', 'Enseignant', 'Admin'];
  static const _roleColors = {
    'Admin': Color(0xFF3B82F6),
    'Enseignant': Color(0xFF8B5CF6),
    'Étudiant': Color(0xFF10B981),
  };

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(adminUsersProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);
    final theme = Theme.of(context);
    final notifier = ref.read(adminUsersProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── AppBar ──────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Utilisateurs',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        )),
                  ),
                  usersAsync.maybeWhen(
                    data: (users) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${users.length}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // ── Barre de recherche ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => notifier.applySearch(v),
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou email…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          notifier.applySearch('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // ── Filtres rôles ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _RoleChip(
                    label: 'Tous',
                    isSelected: _selectedRole == null,
                    color: theme.colorScheme.primary,
                    onSelected: () {
                      setState(() => _selectedRole = null);
                      notifier.applyRoleFilter(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ..._roles.map((r) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _RoleChip(
                          label: r,
                          isSelected: _selectedRole == r,
                          color: _roleColors[r] ?? theme.colorScheme.primary,
                          onSelected: () {
                            setState(() => _selectedRole = r);
                            notifier.applyRoleFilter(r);
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // ── Liste utilisateurs ─────────────────────────────
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                message: e.toString(),
                onRetry: () => notifier.load(refresh: true),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return _EmptyView(onRefresh: () => notifier.load(refresh: true));
                }
                return RefreshIndicator(
                  onRefresh: () => notifier.load(refresh: true),
                  child: ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      if (i == users.length) {
                        return notifier.hasMore
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                      return _UserTile(
                        user: users[i],
                        roleColor: _roleColors[users[i].roleLabel] ?? Colors.grey,
                        onToggleStatus: () => notifier.toggleUserStatus(users[i]),
                        onDelete: () => _confirmDelete(context, users[i], notifier),
                        onEdit: () => _showEditDialog(context, users[i], notifier),
                        onViewDetail: () => _showDetailSheet(context, users[i], notifier),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ── FAB Ajout ─────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, notifier),
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
    );
  }

  // ── Dialogs & Bottom Sheets ────────────────────────────────

  Future<void> _confirmDelete(
      BuildContext context, AdminUserModel user, AdminUsersNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'utilisateur ?'),
        content: Text('${user.fullName} sera définitivement supprimé.'),
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
    if (confirmed == true && context.mounted) {
      try {
        await notifier.deleteUser(user.id);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur supprimé'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showEditDialog(
      BuildContext context, AdminUserModel user, AdminUsersNotifier notifier) async {
    await showDialog(
      context: context,
      builder: (ctx) => AdminUserFormDialog(
        user: user,
        onSave: (fullName, role, phone) async {
          await notifier.updateUser(userId: user.id, fullName: fullName, role: role, phone: phone);
        },
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, AdminUsersNotifier notifier) async {
    await showDialog(
      context: context,
      builder: (ctx) => AdminUserFormDialog(
        onSave: (fullName, role, phone) async {
          // Pour la création l'email et mdp viennent du form
        },
        isCreate: true,
        onCreateUser: ({
          required String email,
          required String password,
          required String fullName,
          required String role,
          String? phone,
        }) async {
          await AdminServiceV2.createUser(
            email: email,
            password: password,
            fullName: fullName,
            role: role,
            phone: phone,
          );
          await notifier.load(refresh: true);
        },
      ),
    );
  }

  Future<void> _showDetailSheet(
      BuildContext context, AdminUserModel user, AdminUsersNotifier notifier) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => AdminUserDetailSheet(
        user: user,
        onToggleStatus: () => notifier.toggleUserStatus(user),
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(context, user, notifier);
        },
        onEdit: () {
          Navigator.pop(context);
          _showEditDialog(context, user, notifier);
        },
      ),
    );
  }
}

// ─── UserTile ─────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  final AdminUserModel user;
  final Color roleColor;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onViewDetail;

  const _UserTile({
    required this.user,
    required this.roleColor,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onEdit,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onViewDetail,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar avec initiales
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!user.isActive)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('Inactif',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.roleLabel,
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'toggle') onToggleStatus();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit, size: 16, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Text('Modifier'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(children: [
                      Icon(user.isActive ? Icons.block : Icons.check_circle,
                          size: 16,
                          color: user.isActive ? Colors.orange : Colors.green),
                      const SizedBox(width: 8),
                      Text(user.isActive ? 'Désactiver' : 'Activer'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete, size: 16, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red.shade600)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Role Chip ────────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onSelected;

  const _RoleChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Form Dialog (Create / Edit) ──────────────────────────────────────────────

class AdminUserFormDialog extends StatefulWidget {
  final AdminUserModel? user;
  final bool isCreate;
  final Future<void> Function(String fullName, String role, String? phone) onSave;
  final Future<void> Function({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  })? onCreateUser;

  const AdminUserFormDialog({
    super.key,
    this.user,
    this.isCreate = false,
    required this.onSave,
    this.onCreateUser,
  });

  @override
  State<AdminUserFormDialog> createState() => _AdminUserFormDialogState();
}

class _AdminUserFormDialogState extends State<AdminUserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _passwordCtrl;
  String _selectedRole = 'Étudiant';
  bool _saving = false;
  bool _obscurePassword = true;

  static const _roles = ['Étudiant', 'Enseignant', 'Admin'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.fullName ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.user?.phone ?? '');
    _passwordCtrl = TextEditingController();
    _selectedRole = widget.user?.roleLabel ?? 'Étudiant';
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (widget.isCreate && widget.onCreateUser != null) {
        await widget.onCreateUser!(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          fullName: _nameCtrl.text.trim(),
          role: _selectedRole,
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Utilisateur créé ✓'), backgroundColor: Colors.green));
        }
      } else {
        await widget.onSave(
          _nameCtrl.text.trim(),
          _selectedRole,
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.isCreate ? 'Nouvel utilisateur' : 'Modifier l\'utilisateur',
          style: const TextStyle(fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet *',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                if (widget.isCreate) ...[
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requis';
                      if (!v.contains('@')) return 'Email invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe *',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, size: 18),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) return '6 caractères min.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rôle *',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(widget.isCreate ? 'Créer' : 'Enregistrer'),
        ),
      ],
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────

class AdminUserDetailSheet extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AdminUserDetailSheet({
    super.key,
    required this.user,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Avatar + nom
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(user.initials,
                        style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        )),
                  ),
                  const SizedBox(height: 12),
                  Text(user.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(user.email, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(user.roleLabel),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                        color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Infos
            _DetailRow(icon: Icons.phone, label: 'Téléphone', value: user.phone ?? '—'),
            _DetailRow(icon: Icons.calendar_today, label: 'Inscrit le',
                value: _formatDate(user.createdAt)),
            if (user.filiere != null)
              _DetailRow(icon: Icons.school, label: 'Filière', value: user.filiere!),
            if (user.departement != null)
              _DetailRow(icon: Icons.business, label: 'Département', value: user.departement!),
            _DetailRow(
              icon: user.isActive ? Icons.check_circle : Icons.block,
              label: 'Statut',
              value: user.isActive ? 'Actif' : 'Inactif',
              valueColor: user.isActive ? Colors.green : Colors.red,
            ),
            const Divider(height: 32),
            // Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Modifier'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(user.isActive ? Icons.block : Icons.check_circle, size: 16),
                  label: Text(user.isActive ? 'Désactiver' : 'Activer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: user.isActive ? Colors.orange : Colors.green,
                    side: BorderSide(color: user.isActive ? Colors.orange : Colors.green),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Supprimer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.iconTheme.color),
          const SizedBox(width: 12),
          Text('$label :', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13, color: valueColor)),
          ),
        ],
      ),
    );
  }
}

// ─── Vues d'état ─────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Aucun utilisateur trouvé',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Erreur de chargement', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
