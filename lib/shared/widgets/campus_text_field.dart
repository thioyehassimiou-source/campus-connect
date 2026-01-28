import 'package:flutter/material.dart';
import 'campus_button.dart';

class CampusTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final CampusTextFieldSize size;
  final CampusTextFieldVariant variant;
  final FocusNode? focusNode;
  final bool showBorder;
  final String? Function(String?)? validator;

  const CampusTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.controller,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.size = CampusTextFieldSize.medium,
    this.variant = CampusTextFieldVariant.outlined,
    this.focusNode,
    this.showBorder = true,
    this.validator,
  });

  @override
  State<CampusTextField> createState() => _CampusTextFieldState();
}

class _CampusTextFieldState extends State<CampusTextField> {
  bool _obscureText = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final isFocused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: _getLabelStyle(hasError),
          ),
          const SizedBox(height: CampusSpacing.sm),
        ],
        
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          focusNode: _focusNode,
          style: _getTextStyle(),
          decoration: _getInputDecoration(hasError, isFocused),
        ),
        
        if (widget.helperText != null) ...[
          const SizedBox(height: CampusSpacing.xs),
          Text(
            widget.helperText!,
            style: CampusTextStyles.bodySmall.copyWith(
              color: hasError ? CampusColors.error : CampusColors.gray500,
            ),
          ),
        ],
        
        if (widget.errorText != null) ...[
          const SizedBox(height: CampusSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: CampusColors.error,
              ),
              const SizedBox(width: CampusSpacing.xs),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: CampusTextStyles.bodySmall.copyWith(
                    color: CampusColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  TextStyle _getLabelStyle(bool hasError) {
    return CampusTextStyles.label.copyWith(
      color: hasError 
          ? CampusColors.error 
          : _focusNode.hasFocus 
              ? CampusColors.primary 
              : CampusColors.gray700,
    );
  }

  TextStyle _getTextStyle() {
    final fontSize = _getFontSize();
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: widget.enabled ? CampusColors.gray900 : CampusColors.gray400,
      height: 1.4,
    );
  }

  InputDecoration _getInputDecoration(bool hasError, bool isFocused) {
    final borderStyle = _getBorderStyle(hasError, isFocused);
    final fillColor = _getFillColor();
    final prefixIcon = _buildPrefixIcon();
    final suffixIcon = _buildSuffixIcon();

    switch (widget.variant) {
      case CampusTextFieldVariant.outlined:
        return InputDecoration(
          hintText: widget.hint,
          hintStyle: _getHintStyle(),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: fillColor,
          contentPadding: _getContentPadding(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: widget.showBorder 
                ? BorderSide(color: CampusColors.gray200, width: 1)
                : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: _getBorderColor(hasError), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: CampusColors.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: CampusColors.error, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: CampusColors.gray100, width: 1),
          ),
        );
      case CampusTextFieldVariant.filled:
        return InputDecoration(
          hintText: widget.hint,
          hintStyle: _getHintStyle(),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: fillColor,
          contentPadding: _getContentPadding(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: _getBorderColor(hasError), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: CampusColors.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: CampusColors.error, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide.none,
          ),
        );
      case CampusTextFieldVariant.underline:
        return InputDecoration(
          hintText: widget.hint,
          hintStyle: _getHintStyle(),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: _getContentPadding(),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: CampusColors.gray200),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: CampusColors.gray200),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: _getBorderColor(hasError), width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: CampusColors.error, width: 2),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: CampusColors.error, width: 2),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: CampusColors.gray100),
          ),
        );
    }
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon == null) return null;
    
    return Icon(
      widget.prefixIcon,
      color: _focusNode.hasFocus ? CampusColors.primary : CampusColors.gray400,
      size: _getIconSize(),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffix != null) return widget.suffix;
    
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: CampusColors.gray400,
          size: _getIconSize(),
        ),
        onPressed: _toggleObscureText,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      );
    }
    
    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: _focusNode.hasFocus ? CampusColors.primary : CampusColors.gray400,
        size: _getIconSize(),
      );
    }
    
    return null;
  }

  TextStyle _getHintStyle() {
    final fontSize = _getFontSize();
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: CampusColors.gray400,
      height: 1.4,
    );
  }

  Color _getFillColor() {
    if (!widget.enabled) return CampusColors.gray100;
    
    switch (widget.variant) {
      case CampusTextFieldVariant.outlined:
        return CampusColors.white;
      case CampusTextFieldVariant.filled:
        return CampusColors.surfaceVariant;
      case CampusTextFieldVariant.underline:
        return Colors.transparent;
    }
  }

  Color _getBorderColor(bool hasError) {
    if (hasError) return CampusColors.error;
    return CampusColors.primary;
  }

  Color _getBorderStyle(bool hasError, bool isFocused) {
    if (hasError) return CampusColors.error;
    if (isFocused) return CampusColors.primary;
    return CampusColors.gray200;
  }

  EdgeInsets _getContentPadding() {
    final verticalPadding = _getVerticalPadding();
    final horizontalPadding = _getHorizontalPadding();
    
    if (widget.prefixIcon != null || widget.suffix != null || widget.suffixIcon != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      );
    }
    
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }

  double _getFontSize() {
    switch (widget.size) {
      case CampusTextFieldSize.small:
        return 14;
      case CampusTextFieldSize.medium:
        return 16;
      case CampusTextFieldSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case CampusTextFieldSize.small:
        return 18;
      case CampusTextFieldSize.medium:
        return 20;
      case CampusTextFieldSize.large:
        return 24;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case CampusTextFieldSize.small:
        return CampusBorderRadius.md;
      case CampusTextFieldSize.medium:
        return CampusBorderRadius.lg;
      case CampusTextFieldSize.large:
        return CampusBorderRadius.xl;
    }
  }

  double _getVerticalPadding() {
    switch (widget.size) {
      case CampusTextFieldSize.small:
        return 12;
      case CampusTextFieldSize.medium:
        return 16;
      case CampusTextFieldSize.large:
        return 20;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.size) {
      case CampusTextFieldSize.small:
        return 12;
      case CampusTextFieldSize.medium:
        return 16;
      case CampusTextFieldSize.large:
        return 20;
    }
  }
}

enum CampusTextFieldSize {
  small,
  medium,
  large,
}

enum CampusTextFieldVariant {
  outlined,
  filled,
  underline,
}
