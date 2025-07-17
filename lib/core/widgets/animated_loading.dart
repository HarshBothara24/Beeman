import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedLoading extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final LoadingType type;

  const AnimatedLoading({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
    this.type = LoadingType.circular,
  });

  @override
  State<AnimatedLoading> createState() => _AnimatedLoadingState();
}

class _AnimatedLoadingState extends State<AnimatedLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primaryColor;

    switch (widget.type) {
      case LoadingType.circular:
        return _buildCircularLoading(color);
      case LoadingType.dots:
        return _buildDotsLoading(color);
      case LoadingType.pulse:
        return _buildPulseLoading(color);
      case LoadingType.wave:
        return _buildWaveLoading(color);
    }
  }

  Widget _buildCircularLoading(Color color) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              strokeWidth: widget.strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: color.withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsLoading(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size / 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final animationValue = (_controller.value - delay).clamp(0.0, 1.0);
              final scale = 0.5 + 0.5 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0);
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size / 6,
                  height: widget.size / 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildPulseLoading(Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveLoading(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size / 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = (_controller.value - delay) % 1.0;
              final height = widget.size / 2 * (0.3 + 0.7 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0));
              
              return Container(
                width: widget.size / 8,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(widget.size / 16),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

enum LoadingType { circular, dots, pulse, wave }

class BeeLoadingAnimation extends StatefulWidget {
  final double size;
  final Color? color;

  const BeeLoadingAnimation({
    super.key,
    this.size = 80,
    this.color,
  });

  @override
  State<BeeLoadingAnimation> createState() => _BeeLoadingAnimationState();
}

class _BeeLoadingAnimationState extends State<BeeLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _flyController;
  late AnimationController _wingsController;
  late Animation<Offset> _flyAnimation;
  late Animation<double> _wingsAnimation;

  @override
  void initState() {
    super.initState();
    
    _flyController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _wingsController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..repeat(reverse: true);

    _flyAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: const Offset(0.5, 0),
    ).animate(CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeInOut,
    ));

    _wingsAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _wingsController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flyController.dispose();
    _wingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primaryColor;

    return SizedBox(
      width: widget.size * 2,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flyAnimation, _wingsAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _flyAnimation.value.dx * widget.size,
              _flyAnimation.value.dy * widget.size * 0.2,
            ),
            child: Transform.scale(
              scale: _wingsAnimation.value,
              child: Icon(
                Icons.emoji_nature,
                size: widget.size,
                color: color,
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final LoadingType loadingType;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.loadingType = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppTheme.softShadow],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedLoading(
                      size: 48,
                      type: loadingType,
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loadingText!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}