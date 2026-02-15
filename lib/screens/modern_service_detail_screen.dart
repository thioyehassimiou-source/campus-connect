import 'package:flutter/material.dart';
import 'package:campusconnect/core/services/campus_service.dart';
import 'package:campusconnect/models/institutional_service.dart';
import 'package:campusconnect/models/announcement.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campusconnect/core/factories/service_features_factory.dart';
// import 'package:campusconnect/screens/modern_announcement_detail_screen.dart'; // Si existe, sinon afficher alerte

class ModernServiceDetailScreen extends StatefulWidget {
  final InstitutionalService service;

  const ModernServiceDetailScreen({super.key, required this.service});

  @override
  State<ModernServiceDetailScreen> createState() => _ModernServiceDetailScreenState();
}

class _ModernServiceDetailScreenState extends State<ModernServiceDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Announcement> _announcements = [];
  bool _isLoadingAnnocuements = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final data = await CampusService.getServiceAnnouncements(widget.service.id);
      if (mounted) {
        setState(() {
          _announcements = data.map((e) => Announcement.fromMap(e)).toList();
          _isLoadingAnnocuements = false;
        });
      }
    } catch (e) {
      print('Erreur annonces: $e');
      if (mounted) {
        setState(() => _isLoadingAnnocuements = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: _getColorForCategory(widget.service.category),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  widget.service.nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                  textAlign: TextAlign.center,
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: _getColorForCategory(widget.service.category),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        _getIconForService(widget.service.nom, widget.service.category),
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: _getColorForCategory(widget.service.category),
                  tabs: const [
                    Tab(text: 'Informations'),
                    Tab(text: 'Actualités'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(),
            _buildNewsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    final s = widget.service;
    final color = _getColorForCategory(s.category);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (s.description != null) ...[
            Text(
              'À PROPOS',
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.description!,
              style: TextStyle(fontSize: 16, height: 1.5, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 24),
          ],

          // Actions Rapides Spécifiques
          _buildQuickActions(color),

          // Coordonnées
          Text(
            'COORDONNÉES',
             style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
          ),
          const SizedBox(height: 16),
          
          if (s.localisation != null)
            _buildInfoRow(Icons.location_on, s.localisation!, color),
          
          if (s.horaires != null)
            _buildInfoRow(Icons.access_time, s.horaires!, color),
            
          if (s.telephone != null)
            _buildInfoRow(Icons.phone, s.telephone!, color, onTap: () => _makePhoneCall(s.telephone!)),

          if (s.email != null)
            _buildInfoRow(Icons.email, s.email!, color, onTap: () => _sendEmail(s.email!)),
            
           if (s.siteWeb != null)
            _buildInfoRow(Icons.language, s.siteWeb!, color, onTap: () => _openWebsite(s.siteWeb!)),

          const SizedBox(height: 24),
          
          // Actions rapides
          Row(
            children: [
              if (s.telephone != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(s.telephone!),
                    icon: const Icon(Icons.call),
                    label: const Text('Appeler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              if (s.telephone != null && s.email != null) const SizedBox(width: 16),
              if (s.email != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sendEmail(s.email!),
                    icon: const Icon(Icons.mail),
                    label: const Text('Email'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
     if (_isLoadingAnnocuements) {
       return const Center(child: CircularProgressIndicator());
     }
     
     if (_announcements.isEmpty) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.feed_outlined, size: 60, color: Colors.grey[300]),
             const SizedBox(height: 16),
             Text(
               'Aucune actualité pour le moment',
               style: TextStyle(color: Colors.grey[600]),
             ),
           ],
         ),
       );
     }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _announcements.length,
      itemBuilder: (context, index) {
        final announcement = _announcements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getColorForCategory(widget.service.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        announcement.priority,
                        style: TextStyle(
                          color: _getColorForCategory(widget.service.category),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(announcement.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  announcement.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  announcement.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], height: 1.4),
                ),
                const SizedBox(height: 12),
                
                // On pourrait ajouter un bouton "Lire plus" si on veut ouvrir un détail d'annonce
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(Color color) {
    final actions = ServiceFeaturesFactory.getActionsForService(widget.service.nom);

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIONS & SERVICES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions.map((action) {
             return _buildActionButton(
               action.icon, 
               action.label, 
               action.color ?? color, // Use action color if defined (e.g., Red for Emergency), else theme color
               () => _handleActionTap(action),
             );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _handleActionTap(ServiceAction action) {
    switch (action.type) {
      case ServiceActionType.navigation:
        // Navigator.pushNamed(context, action.payload!);
        _showActionSnack("Navigation vers ${action.label} (Module en dév)");
        break;
      case ServiceActionType.url:
        if (action.payload != null) _openWebsite(action.payload!);
        break;
      case ServiceActionType.phone:
        if (action.payload != null) _makePhoneCall(action.payload!);
        break;
      case ServiceActionType.email:
        if (action.payload != null) _sendEmail(action.payload!);
        break;
      case ServiceActionType.snackbar:
        _showActionSnack(action.payload ?? "Action effectuée");
        break;
    }
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildInfoRow(IconData icon, String text, Color color, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: onTap != null ? color : Theme.of(context).textTheme.bodyLarge?.color,
                  decoration: onTap != null ? TextDecoration.underline : null,
                  decorationColor: color.withOpacity(0.5),
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  // Helpers
  Color _getColorForCategory(ServiceCategory category) {
    if (widget.service.id == 'ai-assistant') return const Color(0xFF6366F1);
    switch (category) {
       case ServiceCategory.GOVERNANCE: return const Color(0xFF2563EB); // Blue
       case ServiceCategory.ADMIN: return const Color(0xFF059669); // Emerald
       case ServiceCategory.ACADEMIC: return const Color(0xFFEA580C); // Orange
       case ServiceCategory.SUPPORT: return const Color(0xFF7C3AED); // Violet
       default: return Colors.grey;
    }
  }

  IconData _getIconForService(String name, ServiceCategory category) {
      if (widget.service.id == 'ai-assistant') return Icons.psychology_outlined;
      // ... (Same logic as parent, simplified for now)
      return Icons.business; 
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    try { await launchUrl(launchUri); } catch (_) {}
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    try { await launchUrl(launchUri); } catch (_) {}
  }
  
   Future<void> _openWebsite(String url) async {
    final Uri launchUri = Uri.parse(url);
     try { await launchUrl(launchUri); } catch (_) {}
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
