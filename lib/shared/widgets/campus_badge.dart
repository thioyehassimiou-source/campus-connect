import 'package:flutter/material.dart';
import 'campus_design_tokens.dart';

class CampusBadge extends StatelessWidget {
  final String text;
  final CampusBadgeType type;
  final CampusBadgeSize size;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isClickable;

  const CampusBadge({
    super.key,
    required this.text,
    this.type = CampusBadgeType.primary,
    this.size = CampusBadgeSize.medium,
    this.color,
    this.icon,
    this.onTap,
    this.isClickable = false,
  });

  factory CampusBadge.primary({
    required String text,
    CampusBadgeSize size = CampusBadgeSize.medium,
    Color? color,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return CampusBadge(
      text: text,
      type: CampusBadgeType.primary,
      size: size,
      color: color,
      icon: icon,
      onTap: onTap,
    );
  }

  factory CampusBadge.secondary({
    required String text,
    CampusBadgeSize size = CampusBadgeSize.medium,
    Color? color,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return CampusBadge(
      text: text,
      type: CampusBadgeType.secondary,
      size: size,
      color: color,
      icon: icon,
      onTap: onTap,
    );
  }

  factory CampusBadge.success({
    required String text,
    CampusBadgeSize size = CampusBadgeSize.medium,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return CampusBadge(
      text: text,
      type: CampusBadgeType.success,
      size: size,
      icon: icon,
      onTap: onTap,
    );
  }

  factory CampusBadge.warning({
    required String text,
    CampusBadgeSize size = CampusBadgeSize.medium,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return CampusBadge(
      text: text,
      type: CampusBadgeType.warning,
      size: size,
      icon: icon,
      onTap: onTap,
    );
  }

  factory CampusBadge.error({
    required String text,
    CampusBadgeSize size = CampusBadgeSize.medium,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return CampusBadge(
      text: text,
      type: CampusBadgeType.error,
      size: size,
      icon: icon,
      onTap: onTap,
    );
  }

  factory CampusBadge.info({
    required String text,
    CampusBadgeSize size = CampusBadgeSize.medium,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return CampusBadge(
      text: text,
      type: CampusBadgeType.info,
      size: size,
      icon: icon,
      onTap: onTap,
    );
  }

  factory CampusBadge.outline({
    required String text,
    CampusBadgeSize size = CampusBadgeSize.medium,
    Color? color,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return CampusBadge(
      text: text,
      type: CampusBadgeType.outline,
      size: size,
      color: color,
      icon: icon,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor();
    final backgroundColor = _getBackgroundColor(badgeColor);
    final textColor = _getTextColor(badgeColor);
    final padding = _getPadding();
    final borderRadius = _getBorderRadius();
    final textStyle = _getTextStyle(textColor);
    final iconSize = _getIconSize();

    Widget badgeChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: iconSize,
            color: textColor,
          ),
          const SizedBox(width: CampusSpacing.xs),
        ],
        Flexible(
          child: Text(
            text,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final badge = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: type == CampusBadgeType.outline
            ? Border.all(color: badgeColor, width: 1)
            : null,
      ),
      child: badgeChild,
    );

    if (onTap != null || isClickable) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: badge,
      );
    }

    return badge;
  }

  Color _getBadgeColor() {
    if (color != null) return color!;
    
    switch (type) {
      case CampusBadgeType.primary:
        return CampusColors.primary;
      case CampusBadgeType.secondary:
        return CampusColors.secondary;
      case CampusBadgeType.success:
        return CampusColors.success;
      case CampusBadgeType.warning:
        return CampusColors.warning;
      case CampusBadgeType.error:
        return CampusColors.error;
      case CampusBadgeType.info:
        return CampusColors.info;
      case CampusBadgeType.outline:
        return CampusColors.primary;
    }
  }

  Color _getBackgroundColor(Color badgeColor) {
    switch (type) {
      case CampusBadgeType.primary:
      case CampusBadgeType.secondary:
      case CampusBadgeType.success:
      case CampusBadgeType.warning:
      case CampusBadgeType.error:
      case CampusBadgeType.info:
        return badgeColor.withOpacity(0.1);
      case CampusBadgeType.outline:
        return Colors.transparent;
    }
  }

  Color _getTextColor(Color badgeColor) {
    switch (type) {
      case CampusBadgeType.primary:
      case CampusBadgeType.secondary:
      case CampusBadgeType.success:
      case CampusBadgeType.warning:
      case CampusBadgeType.error:
      case CampusBadgeType.info:
        return badgeColor;
      case CampusBadgeType.outline:
        return badgeColor;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case CampusBadgeSize.small:
        return const EdgeInsets.symmetric(
          horizontal: CampusSpacing.sm,
          vertical: CampusSpacing.xs,
        );
      case CampusBadgeSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: CampusSpacing.md,
          vertical: CampusSpacing.sm,
        );
      case CampusBadgeSize.large:
        return const EdgeInsets.symmetric(
          horizontal: CampusSpacing.lg,
          vertical: CampusSpacing.md,
        );
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case CampusBadgeSize.small:
        return CampusBorderRadius.sm;
      case CampusBadgeSize.medium:
        return CampusBorderRadius.md;
      case CampusBadgeSize.large:
        return CampusBorderRadius.lg;
    }
  }

  TextStyle _getTextStyle(Color textColor) {
    final fontSize = _getFontSize();
    final fontWeight = _getFontWeight();
    
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor,
      height: 1.2,
    );
  }

  double _getFontSize() {
    switch (size) {
      case CampusBadgeSize.small:
        return 10;
      case CampusBadgeSize.medium:
        return 12;
      case CampusBadgeSize.large:
        return 14;
    }
  }

  FontWeight _getFontWeight() {
    return FontWeight.w600;
  }

  double _getIconSize() {
    switch (size) {
      case CampusBadgeSize.small:
        return 12;
      case CampusBadgeSize.medium:
        return 14;
      case CampusBadgeSize.large:
        return 16;
    }
  }
}

enum CampusBadgeType {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
  outline,
}

enum CampusBadgeSize {
  small,
  medium,
  large,
}

// Badge spécialisés pour des usages courants
class CampusStatusBadge extends StatelessWidget {
  final String text;
  final CampusStatus status;
  final CampusBadgeSize size;
  final VoidCallback? onTap;

  const CampusStatusBadge({
    super.key,
    required this.text,
    required this.status,
    this.size = CampusBadgeSize.medium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case CampusStatus.active:
        return CampusBadge.success(
          text: text,
          size: size,
          icon: Icons.check_circle,
          onTap: onTap,
        );
      case CampusStatus.inactive:
        return CampusBadge.secondary(
          text: text,
          size: size,
          icon: Icons.remove_circle,
          onTap: onTap,
        );
      case CampusStatus.pending:
        return CampusBadge.warning(
          text: text,
          size: size,
          icon: Icons.pending,
          onTap: onTap,
        );
      case CampusStatus.completed:
        return CampusBadge.primary(
          text: text,
          size: size,
          icon: Icons.task_alt,
          onTap: onTap,
        );
      case CampusStatus.cancelled:
        return CampusBadge.error(
          text: text,
          size: size,
          icon: Icons.cancel,
          onTap: onTap,
        );
    }
  }
}

enum CampusStatus {
  active,
  inactive,
  pending,
  completed,
  cancelled,
}

class CampusRoleBadge extends StatelessWidget {
  final String text;
  final CampusRole role;
  final CampusBadgeSize size;
  final VoidCallback? onTap;

  const CampusRoleBadge({
    super.key,
    required this.text,
    required this.role,
    this.size = CampusBadgeSize.medium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case CampusRole.student:
        return CampusBadge(
          text: text,
          type: CampusBadgeType.primary,
          size: size,
          color: CampusColors.student,
          icon: Icons.school,
          onTap: onTap,
        );
      case CampusRole.teacher:
        return CampusBadge(
          text: text,
          type: CampusBadgeType.primary,
          size: size,
          color: CampusColors.teacher,
          icon: Icons.person,
          onTap: onTap,
        );
      case CampusRole.admin:
        return CampusBadge(
          text: text,
          type: CampusBadgeType.primary,
          size: size,
          color: CampusColors.admin,
          icon: Icons.admin_panel_settings,
          onTap: onTap,
        );
    }
  }
}

enum CampusRole {
  student,
  teacher,
  admin,
}

class CampusPriorityBadge extends StatelessWidget {
  final String text;
  final CampusPriority priority;
  final CampusBadgeSize size;
  final VoidCallback? onTap;

  const CampusPriorityBadge({
    super.key,
    required this.text,
    required this.priority,
    this.size = CampusBadgeSize.medium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (priority) {
      case CampusPriority.low:
        return CampusBadge.secondary(
          text: text,
          size: size,
          icon: Icons.low_priority,
          onTap: onTap,
        );
      case CampusPriority.medium:
        return CampusBadge.info(
          text: text,
          size: size,
          icon: Icons.info_outline,
          onTap: onTap,
        );
      case CampusPriority.high:
        return CampusBadge.warning(
          text: text,
          size: size,
          icon: Icons.warning,
          onTap: onTap,
        );
      case CampusPriority.urgent:
        return CampusBadge.error(
          text: text,
          size: size,
          icon: Icons.priority_high,
          onTap: onTap,
        );
    }
  }
}

enum CampusPriority {
  low,
  medium,
  high,
  urgent,
}
