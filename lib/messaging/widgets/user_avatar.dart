import 'package:flutter/material.dart';

enum UserStatus { online, away, offline }

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final UserStatus status;
  final bool showStatus;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24,
    this.status = UserStatus.online,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.8,
                  ),
                )
              : null,
        ),
        if (showStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.6,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case UserStatus.online:
        return Colors.green;
      case UserStatus.away:
        return Colors.orange;
      case UserStatus.offline:
        return Colors.grey;
    }
  }
}
