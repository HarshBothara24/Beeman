import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class EnhancedAdminCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isNew;
  final bool isEnabled;

  const EnhancedAdminCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isNew = false,
    this.isEnabled = true,
  });

  @override
  State<EnhancedAdminCard> createState() => _EnhancedAdminCardState();
}

class _EnhancedAdminCardState extends State<EnhancedAdminCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _shadowColorAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shadowColorAnimation = ColorTween(
      begin: widget.color.withOpacity(0.1),
      end: widget.color.withOpacity(0.3),
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

  void _onHoverChanged(bool isHovered) {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (!widget.isEnabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.98 : _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHoverChanged(true),
            onExit: (_) => _onHoverChanged(false),
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.isEnabled ? widget.onTap : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: widget.isEnabled 
                      ? (themeProvider.isDarkMode 
                          ? AppTheme.darkSurfaceColor 
                          : AppTheme.surfaceColor)
                      : (themeProvider.isDarkMode 
                          ? AppTheme.darkSurfaceColor.withOpacity(0.5) 
                          : AppTheme.surfaceColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered && widget.isEnabled
                        ? widget.color.withOpacity(0.3)
                        : (themeProvider.isDarkMode 
                            ? AppTheme.darkBorderColor 
                            : AppTheme.dividerColor),
                    width: _isHovered && widget.isEnabled ? 1.5 : 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _shadowColorAnimation.value ?? widget.color.withOpacity(0.1),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Gradient overlay on hover
                    if (_isHovered && widget.isEnabled)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                widget.color.withOpacity(0.05),
                                widget.color.withOpacity(0.02),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon container with animation
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _isHovered && widget.isEnabled
                                  ? widget.color.withOpacity(0.15)
                                  : widget.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: AnimatedRotation(
                              turns: _isHovered && widget.isEnabled ? 0.05 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                widget.icon,
                                color: widget.isEnabled 
                                    ? widget.color 
                                    : widget.color.withOpacity(0.5),
                                size: 32,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Title with animation
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: _isHovered && widget.isEnabled ? 19 : 18,
                              fontWeight: FontWeight.bold,
                              color: widget.isEnabled 
                                  ? (themeProvider.isDarkMode 
                                      ? AppTheme.darkTextPrimary 
                                      : AppTheme.textPrimary)
                                  : (themeProvider.isDarkMode 
                                      ? AppTheme.darkTextMuted 
                                      : AppTheme.textMuted),
                            ),
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Subtitle
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 12, // slightly reduced for better fit
                              color: widget.isEnabled 
                                  ? (themeProvider.isDarkMode 
                                      ? AppTheme.darkTextSecondary 
                                      : AppTheme.textSecondary)
                                  : (themeProvider.isDarkMode 
                                      ? AppTheme.darkTextMuted 
                                      : AppTheme.textMuted),
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3, // allow up to 3 lines
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          // Animated arrow indicator
                          if (_isHovered && widget.isEnabled)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: AnimatedSlide(
                                duration: const Duration(milliseconds: 200),
                                offset: _isHovered ? const Offset(0.1, 0) : Offset.zero,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: widget.color,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Badge
                    if (widget.isNew)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}