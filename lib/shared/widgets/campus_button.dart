import 'package:flutter/material.dart';

class CampusButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CampusButtonType type;
  final CampusButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? child;

  const CampusButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CampusButtonType.primary,
    this.size = CampusButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  });

  factory CampusButton.primary({
    required String text,
    VoidCallback? onPressed,
    CampusButtonSize size = CampusButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
  }) {
    return CampusButton(
      text: text,
      onPressed: onPressed,
      type: CampusButtonType.primary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
    );
  }

  factory CampusButton.secondary({
    required String text,
    VoidCallback? onPressed,
    CampusButtonSize size = CampusButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
  }) {
    return CampusButton(
      text: text,
      onPressed: onPressed,
      type: CampusButtonType.secondary,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
    );
  }

  factory CampusButton.outline({
    required String text,
    VoidCallback? onPressed,
    CampusButtonSize size = CampusButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
  }) {
    return CampusButton(
      text: text,
      onPressed: onPressed,
      type: CampusButtonType.outline,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
    );
  }

  factory CampusButton.text({
    required String text,
    VoidCallback? onPressed,
    CampusButtonSize size = CampusButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
  }) {
    return CampusButton(
      text: text,
      onPressed: onPressed,
      type: CampusButtonType.text,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();
    final padding = _getPadding();
    final borderRadius = _getBorderRadius();

    Widget buttonChild = child ?? _buildDefaultChild(textStyle);

    if (isFullWidth) {
      buttonChild = SizedBox(
        width: double.infinity,
        child: buttonChild,
      );
    }

    switch (type) {
      case CampusButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonStyle.backgroundColor,
            foregroundColor: buttonStyle.foregroundColor,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            elevation: 0,
            disabledBackgroundColor: buttonStyle.disabledBackgroundColor,
          ),
          child: buttonChild,
        );
      case CampusButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonStyle.backgroundColor,
            foregroundColor: buttonStyle.foregroundColor,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            elevation: 0,
            disabledBackgroundColor: buttonStyle.disabledBackgroundColor,
          ),
          child: buttonChild,
        );
      case CampusButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: buttonStyle.foregroundColor,
            side: BorderSide(
              color: buttonStyle.foregroundColor!,
              width: 1.5,
            ),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            disabledForegroundColor: buttonStyle.disabledForegroundColor,
          ),
          child: buttonChild,
        );
      case CampusButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: buttonStyle.foregroundColor,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            disabledForegroundColor: buttonStyle.disabledForegroundColor,
          ),
          child: buttonChild,
        );
    }
  }

  Widget _buildDefaultChild(TextStyle textStyle) {
    if (isLoading) {
      return SizedBox(
        width: _getLoadingSize(),
        height: _getLoadingSize(),
        child: FittedBox(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              type == CampusButtonType.primary ? Colors.white : CampusColors.primary,
            ),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getIconSize(),
            color: textStyle.color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: textStyle,
          ),
        ],
      );
    }

    return Text(
      text,
      style: textStyle,
    );
  }

  _ButtonStyle _getButtonStyle() {
    switch (type) {
      case CampusButtonType.primary:
        return _ButtonStyle(
          backgroundColor: CampusColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: CampusColors.primary.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
        );
      case CampusButtonType.secondary:
        return _ButtonStyle(
          backgroundColor: CampusColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: CampusColors.secondary.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
        );
      case CampusButtonType.outline:
        return _ButtonStyle(
          backgroundColor: Colors.transparent,
          foregroundColor: CampusColors.primary,
          disabledForegroundColor: CampusColors.primary.withOpacity(0.5),
        );
      case CampusButtonType.text:
        return _ButtonStyle(
          backgroundColor: Colors.transparent,
          foregroundColor: CampusColors.primary,
          disabledForegroundColor: CampusColors.primary.withOpacity(0.5),
        );
    }
  }

  TextStyle _getTextStyle() {
    final fontSize = _getFontSize();
    final fontWeight = _getFontWeight();
    final color = _getButtonStyle().foregroundColor;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.2,
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case CampusButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case CampusButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case CampusButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  BorderRadius _getBorderRadius() {
    switch (size) {
      case CampusButtonSize.small:
        return BorderRadius.circular(8);
      case CampusButtonSize.medium:
        return BorderRadius.circular(12);
      case CampusButtonSize.large:
        return BorderRadius.circular(16);
    }
  }

  double _getFontSize() {
    switch (size) {
      case CampusButtonSize.small:
        return 14;
      case CampusButtonSize.medium:
        return 16;
      case CampusButtonSize.large:
        return 18;
    }
  }

  FontWeight _getFontWeight() {
    return FontWeight.w600;
  }

  double _getIconSize() {
    switch (size) {
      case CampusButtonSize.small:
        return 16;
      case CampusButtonSize.medium:
        return 18;
      case CampusButtonSize.large:
        return 20;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case CampusButtonSize.small:
        return 16;
      case CampusButtonSize.medium:
        return 20;
      case CampusButtonSize.large:
        return 24;
    }
  }
}

enum CampusButtonType {
  primary,
  secondary,
  outline,
  text,
}

enum CampusButtonSize {
  small,
  medium,
  large,
}

class _ButtonStyle {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;

  _ButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
  });
}

class CampusColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Background colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  
  // Role colors
  static const Color student = Color(0xFF2563EB);
  static const Color teacher = Color(0xFF10B981);
  static const Color admin = Color(0xFFDC2626);
}

class CampusTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: CampusColors.gray900,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: CampusColors.gray900,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: CampusColors.gray900,
    height: 1.3,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: CampusColors.gray900,
    height: 1.3,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: CampusColors.gray700,
    height: 1.4,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: CampusColors.gray600,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: CampusColors.gray500,
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: CampusColors.gray400,
    height: 1.4,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: CampusColors.gray700,
    height: 1.2,
  );
}

class CampusSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class CampusBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double full = 50.0;
}
