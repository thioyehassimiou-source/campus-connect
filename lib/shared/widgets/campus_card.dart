import 'package:flutter/material.dart';
import 'campus_button.dart';

class CampusCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? surfaceColor;
  final double? elevation;
  final double? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final CampusCardVariant variant;
  final CampusCardSize size;
  final bool isClickable;
  final Widget? header;
  final Widget? footer;
  final List<Widget>? actions;

  const CampusCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.surfaceColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.onTap,
    this.variant = CampusCardVariant.elevated,
    this.size = CampusCardSize.medium,
    this.isClickable = false,
    this.header,
    this.footer,
    this.actions,
  });

  factory CampusCard.elevated({
    Widget? child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? elevation,
    double? borderRadius,
    Border? border,
    VoidCallback? onTap,
    CampusCardSize size = CampusCardSize.medium,
    Widget? header,
    Widget? footer,
    List<Widget>? actions,
  }) {
    return CampusCard(
      child: child,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
      variant: CampusCardVariant.elevated,
      size: size,
      header: header,
      footer: footer,
      actions: actions,
    );
  }

  factory CampusCard.outlined({
    Widget? child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? borderRadius,
    Border? border,
    VoidCallback? onTap,
    CampusCardSize size = CampusCardSize.medium,
    Widget? header,
    Widget? footer,
    List<Widget>? actions,
  }) {
    return CampusCard(
      child: child,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
      variant: CampusCardVariant.outlined,
      size: size,
      header: header,
      footer: footer,
      actions: actions,
    );
  }

  factory CampusCard.filled({
    Widget? child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? borderRadius,
    VoidCallback? onTap,
    CampusCardSize size = CampusCardSize.medium,
    Widget? header,
    Widget? footer,
    List<Widget>? actions,
  }) {
    return CampusCard(
      child: child,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      onTap: onTap,
      variant: CampusCardVariant.filled,
      size: size,
      header: header,
      footer: footer,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardWidget = _buildCard();
    
    if (onTap != null || isClickable) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: cardWidget,
      );
    }
    
    return cardWidget;
  }

  Widget _buildCard() {
    final effectiveBackgroundColor = _getBackgroundColor();
    final effectiveElevation = _getElevation();
    final effectiveBorderRadius = _getBorderRadius();
    final effectiveBorder = _getBorder();
    final effectivePadding = _getPadding();
    final effectiveMargin = _getMargin();

    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[
          _buildHeader(),
          if (child != null) const SizedBox(height: CampusSpacing.md),
        ],
        if (child != null) child!,
        if (footer != null) ...[
          if (child != null) const SizedBox(height: CampusSpacing.md),
          _buildFooter(),
        ],
      ],
    );

    if (effectivePadding != null) {
      cardContent = Padding(
        padding: effectivePadding,
        child: cardContent,
      );
    }

    Widget card;
    switch (variant) {
      case CampusCardVariant.elevated:
        card = Card(
          elevation: effectiveElevation,
          color: effectiveBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            side: effectiveBorder != null 
                ? effectiveBorder! 
                : BorderSide.none,
          ),
          child: cardContent,
        );
        break;
      case CampusCardVariant.outlined:
        card = Container(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            border: effectiveBorder ?? Border.all(
              color: CampusColors.gray200,
              width: 1,
            ),
          ),
          child: cardContent,
        );
        break;
      case CampusCardVariant.filled:
        card = Container(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            border: effectiveBorder,
          ),
          child: cardContent,
        );
        break;
    }

    if (effectiveMargin != null) {
      card = Padding(
        padding: effectiveMargin,
        child: card,
      );
    }

    return card;
  }

  Widget _buildHeader() {
    if (actions != null && actions!.isNotEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: header!),
          ...actions!,
        ],
      );
    }
    return header!;
  }

  Widget _buildFooter() {
    return footer!;
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;
    
    switch (variant) {
      case CampusCardVariant.elevated:
        return CampusColors.surface;
      case CampusCardVariant.outlined:
        return CampusColors.surface;
      case CampusCardVariant.filled:
        return CampusColors.surfaceVariant;
    }
  }

  double _getElevation() {
    if (elevation != null) return elevation!;
    
    switch (variant) {
      case CampusCardVariant.elevated:
        switch (size) {
          case CampusCardSize.small:
            return 2;
          case CampusCardSize.medium:
            return 4;
          case CampusCardSize.large:
            return 8;
        }
      case CampusCardVariant.outlined:
      case CampusCardVariant.filled:
        return 0;
    }
  }

  double _getBorderRadius() {
    if (borderRadius != null) return borderRadius!;
    
    switch (size) {
      case CampusCardSize.small:
        return CampusBorderRadius.md;
      case CampusCardSize.medium:
        return CampusBorderRadius.lg;
      case CampusCardSize.large:
        return CampusBorderRadius.xl;
    }
  }

  Border? _getBorder() {
    if (border != null) return border;
    
    switch (variant) {
      case CampusCardVariant.elevated:
      case CampusCardVariant.filled:
        return null;
      case CampusCardVariant.outlined:
        return Border.all(color: CampusColors.gray200, width: 1);
    }
  }

  EdgeInsets? _getPadding() {
    if (padding != null) return padding;
    
    switch (size) {
      case CampusCardSize.small:
        return const EdgeInsets.all(CampusSpacing.md);
      case CampusCardSize.medium:
        return const EdgeInsets.all(CampusSpacing.lg);
      case CampusCardSize.large:
        return const EdgeInsets.all(CampusSpacing.xl);
    }
  }

  EdgeInsets? _getMargin() {
    return margin;
  }
}

enum CampusCardVariant {
  elevated,
  outlined,
  filled,
}

enum CampusCardSize {
  small,
  medium,
  large,
}

// Card spécialisés pour des usages courants
class CampusInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final CampusCardSize size;
  final Widget? trailing;

  const CampusInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    this.size = CampusCardSize.medium,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return CampusCard.outlined(
      onTap: onTap,
      size: size,
      padding: _getPadding(),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: _getIconSize(),
              height: _getIconSize(),
              decoration: BoxDecoration(
                color: (iconColor ?? CampusColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(_getIconBorderRadius()),
              ),
              child: Icon(
                icon,
                color: iconColor ?? CampusColors.primary,
                size: _getIconSize() * 0.6,
              ),
            ),
            SizedBox(width: _getSpacing()),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _getTitleStyle(),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: CampusSpacing.xs),
                  Text(
                    subtitle!,
                    style: _getSubtitleStyle(),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (trailing == null && onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: CampusColors.gray400,
            ),
        ],
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case CampusCardSize.small:
        return const EdgeInsets.all(CampusSpacing.md);
      case CampusCardSize.medium:
        return const EdgeInsets.all(CampusSpacing.lg);
      case CampusCardSize.large:
        return const EdgeInsets.all(CampusSpacing.xl);
    }
  }

  double _getIconSize() {
    switch (size) {
      case CampusCardSize.small:
        return 40;
      case CampusCardSize.medium:
        return 48;
      case CampusCardSize.large:
        return 56;
    }
  }

  double _getIconBorderRadius() {
    switch (size) {
      case CampusCardSize.small:
        return CampusBorderRadius.md;
      case CampusCardSize.medium:
        return CampusBorderRadius.lg;
      case CampusCardSize.large:
        return CampusBorderRadius.xl;
    }
  }

  double _getSpacing() {
    return CampusSpacing.md;
  }

  TextStyle _getTitleStyle() {
    switch (size) {
      case CampusCardSize.small:
        return CampusTextStyles.body.copyWith(fontWeight: FontWeight.w600);
      case CampusCardSize.medium:
        return CampusTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600);
      case CampusCardSize.large:
        return CampusTextStyles.h4.copyWith(fontWeight: FontWeight.w700);
    }
  }

  TextStyle _getSubtitleStyle() {
    switch (size) {
      case CampusCardSize.small:
        return CampusTextStyles.bodySmall;
      case CampusCardSize.medium:
        return CampusTextStyles.body;
      case CampusCardSize.large:
        return CampusTextStyles.bodyLarge;
    }
  }
}

class CampusStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final CampusCardSize size;
  final VoidCallback? onTap;

  const CampusStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.size = CampusCardSize.medium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CampusCard.elevated(
      onTap: onTap,
      size: size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: _getIconSize(),
                  height: _getIconSize(),
                  decoration: BoxDecoration(
                    color: (iconColor ?? CampusColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(_getIconBorderRadius()),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? CampusColors.primary,
                    size: _getIconSize() * 0.6,
                  ),
                ),
                const Spacer(),
              ],
            ],
          ),
          SizedBox(height: _getSpacing()),
          Text(
            value,
            style: _getValueStyle(),
          ),
          SizedBox(height: CampusSpacing.xs),
          Text(
            title,
            style: _getTitleStyle(),
          ),
          if (subtitle != null) ...[
            SizedBox(height: CampusSpacing.xs),
            Text(
              subtitle!,
              style: _getSubtitleStyle(),
            ),
          ],
        ],
      ),
    );
  }

  double _getIconSize() {
    switch (size) {
      case CampusCardSize.small:
        return 32;
      case CampusCardSize.medium:
        return 40;
      case CampusCardSize.large:
        return 48;
    }
  }

  double _getIconBorderRadius() {
    return CampusBorderRadius.md;
  }

  double _getSpacing() {
    return CampusSpacing.sm;
  }

  TextStyle _getValueStyle() {
    final color = iconColor ?? CampusColors.primary;
    switch (size) {
      case CampusCardSize.small:
        return CampusTextStyles.h3.copyWith(color: color);
      case CampusCardSize.medium:
        return CampusTextStyles.h2.copyWith(color: color);
      case CampusCardSize.large:
        return CampusTextStyles.h1.copyWith(color: color);
    }
  }

  TextStyle _getTitleStyle() {
    switch (size) {
      case CampusCardSize.small:
        return CampusTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600);
      case CampusCardSize.medium:
        return CampusTextStyles.body.copyWith(fontWeight: FontWeight.w600);
      case CampusCardSize.large:
        return CampusTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600);
    }
  }

  TextStyle _getSubtitleStyle() {
    return CampusTextStyles.bodySmall;
  }
}
