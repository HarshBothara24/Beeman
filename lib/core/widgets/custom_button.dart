import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outlined, text, gradient }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final Widget? iconWidget;
  final bool fullWidth;
  final EdgeInsets? padding;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.iconWidget,
    this.fullWidth = false,
    this.padding,
    this.borderRadius = 12,
    this.boxShadow,
    this.gradient,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildButton(context),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    
    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.fullWidth ? double.infinity : widget.width,
        height: widget.height ?? 56,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: _getButtonDecoration(isDisabled),
        child: _buildButtonContent(),
      ),
    );
  }

  BoxDecoration _getButtonDecoration(bool isDisabled) {
    Color backgroundColor;
    Color borderColor = Colors.transparent;
    List<BoxShadow> shadows = [];

    switch (widget.variant) {
      case ButtonVariant.primary:
        backgroundColor = isDisabled
            ? AppTheme.textMuted
            : (widget.backgroundColor ?? AppTheme.primaryColor);
        if (!isDisabled) {
          shadows = widget.boxShadow ?? [
            BoxShadow(
              color: (widget.backgroundColor ?? AppTheme.primaryColor).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ];
        }
        break;
      case ButtonVariant.secondary:
        backgroundColor = isDisabled
            ? AppTheme.dividerColor
            : (widget.backgroundColor ?? AppTheme.secondaryColor);
        break;
      case ButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        borderColor = isDisabled
            ? AppTheme.textMuted
            : (widget.borderColor ?? AppTheme.primaryColor);
        break;
      case ButtonVariant.text:
        backgroundColor = Colors.transparent;
        break;
      case ButtonVariant.gradient:
        backgroundColor = Colors.transparent;
        break;
    }

    if (widget.variant == ButtonVariant.gradient) {
      return BoxDecoration(
        gradient: isDisabled
            ? const LinearGradient(colors: [AppTheme.textMuted, AppTheme.textMuted])
            : (widget.gradient ?? AppTheme.primaryGradient),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: borderColor != Colors.transparent
            ? Border.all(color: borderColor, width: 1.5)
            : null,
        boxShadow: isDisabled ? null : shadows,
      );
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: borderColor != Colors.transparent
          ? Border.all(color: borderColor, width: 1.5)
          : null,
      boxShadow: isDisabled ? null : shadows,
    );
  }

  Widget _buildButtonContent() {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    Color textColor;

    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.gradient:
        textColor = isDisabled
            ? AppTheme.textLight.withOpacity(0.6)
            : (widget.textColor ?? AppTheme.textLight);
        break;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        textColor = isDisabled
            ? AppTheme.textMuted
            : (widget.textColor ?? AppTheme.primaryColor);
        break;
    }

    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.iconWidget != null) ...[
          widget.iconWidget!,
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Specialized button variants for common use cases
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.outlined,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final Gradient? gradient;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.gradient,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
      gradient: gradient,
    );
  }
}