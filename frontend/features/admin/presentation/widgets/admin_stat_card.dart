import 'package:flutter/material.dart';

class AdminStatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const AdminStatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });
}

/// Carte KPI du dashboard admin — compacte et colorée.
class AdminStatCard extends StatelessWidget {
  final AdminStatCardData data;
  final VoidCallback? onTap;

  const AdminStatCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Material(
      color: isDark
          ? data.color.withOpacity(0.12)
          : data.color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: data.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(data.icon, color: data.color, size: 18),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: data.color.withOpacity(0.6)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: data.color,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '${data.label}${data.subtitle != null ? ' · ${data.subtitle}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
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
