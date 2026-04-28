import 'package:flutter/material.dart';
import 'campus_design_tokens.dart';

// ... (other imports if any)


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

// End of CampusButton file
