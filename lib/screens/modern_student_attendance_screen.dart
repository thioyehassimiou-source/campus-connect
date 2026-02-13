import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/shared/models/attendance_model.dart';
import 'package:campusconnect/controllers/attendance_providers.dart';
import 'package:intl/intl.dart';

class ModernStudentAttendanceScreen extends ConsumerStatefulWidget {
  const ModernStudentAttendanceScreen({super.key});

  @override
  ConsumerState<ModernStudentAttendanceScreen> createState() => _ModernStudentAttendanceScreenState();
}

class _ModernStudentAttendanceScreenState extends ConsumerState<ModernStudentAttendanceScreen> {
  String _selectedMonth = 'Février 2025';
  // Removed local data

  @override
  void initState() {
    super.initState();
    // Géré par Riverpod
  }

  void _refreshData() {
    ref.invalidate(studentAttendanceProvider);
    ref.invalidate(studentAttendanceStatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ma Présence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const Text(
              'Historique d\'assiduité',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF64748B)),
            onPressed: _exportAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          // Carte de statistiques
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(studentAttendanceStatsProvider);
              
              return statsAsync.when(
                data: (stats) => Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tableau de bord',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Statistiques globales',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAttendanceStatCard(
                              'Taux de présence',
                              '${stats.attendanceRate.toStringAsFixed(1)}%',
                              Icons.check_circle,
                              Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAttendanceStatCard(
                              'Présences',
                              '${stats.presentClasses}',
                              Icons.present_to_all,
                              Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAttendanceStatCard(
                              'Absences',
                              '${stats.absentClasses}',
                              Icons.cancel,
                              Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Barre de progression
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (stats.attendanceRate / 100).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (e, st) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erreur stats: $e', style: const TextStyle(color: Colors.red)),
                ),
              );
            },
          ),
          
          // Filtre par mois
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Mois',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                      items: [
                        'Novembre 2024',
                        'Décembre 2024',
                        'Janvier 2025',
                        'Février 2025',
                      ]
                          .map((month) => DropdownMenuItem(
                                value: month,
                                child: Text(
                                  month,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Légende
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildLegendItem('Présent', const Color(0xFF10B981), Icons.check_circle),
                const SizedBox(width: 16),
                _buildLegendItem('Retard', const Color(0xFFF59E0B), Icons.schedule),
                const SizedBox(width: 16),
                _buildLegendItem('Absent', const Color(0xFFEF4444), Icons.cancel),
              ],
            ),
          ),
          
          // Liste des présences
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final attendanceAsync = ref.watch(studentAttendanceProvider);
                
                return attendanceAsync.when(
                  data: (records) {
                    if (records.isEmpty) {
                      return const Center(child: Text('Aucun enregistrement de présence.'));
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        return _buildAttendanceCard(records[index]);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Erreur: $e')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record) {
    final status = record.status;
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.course,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enregistré le ${DateFormat('dd/MM/yyyy').format(record.date)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 12,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    DateFormat('HH:mm').format(record.date),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (record.room != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      record.room!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                const Spacer(),
                if (record.justified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Justifié',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return const Color(0xFF10B981);
      case 'late':
        return const Color(0xFFF59E0B);
      case 'absent':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'late':
        return Icons.schedule;
      case 'absent':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'Présent';
      case 'late':
        return 'Retard';
      case 'absent':
        return 'Absent';
      default:
        return 'Inconnu';
    }
  }

  void _exportAttendance() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Exporter ma présence'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
                title: Text('Attestation de présence PDF'),
                subtitle: Text('Document officiel pour administration'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Génération de l\'attestation en cours...'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart, color: Color(0xFF10B981)),
                title: Text('Historique Excel'),
                subtitle: Text('Détail complet des présences'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export Excel en cours...'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }
}
