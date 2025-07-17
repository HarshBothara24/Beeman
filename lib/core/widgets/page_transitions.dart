import 'package:flutter/material.dart';

enum TransitionType {
  fade,
  slide,
  scale,
  rotation,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scaleRotate,
  fadeSlide,
}

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final TransitionType transitionType;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;

  CustomPageRoute({
    required this.child,
    this.transitionType = TransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    switch (transitionType) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );

      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: curvedAnimation,
          child: child,
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: curvedAnimation,
          child: child,
        );

      case TransitionType.scaleRotate:
        return ScaleTransition(
          scale: curvedAnimation,
          child: RotationTransition(
            turns: Tween<double>(
              begin: 0.0,
              end: 0.1,
            ).animate(curvedAnimation),
            child: child,
          ),
        );

      case TransitionType.fadeSlide:
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
    }
  }
}

class PageTransitions {
  static Route<T> fadeTransition<T>(Widget page, {RouteSettings? settings}) {
    return CustomPageRoute<T>(
      child: page,
      transitionType: TransitionType.fade,
      settings: settings,
    );
  }

  static Route<T> slideTransition<T>(Widget page, {RouteSettings? settings}) {
    return CustomPageRoute<T>(
      child: page,
      transitionType: TransitionType.slide,
      settings: settings,
    );
  }

  static Route<T> slideUpTransition<T>(Widget page, {RouteSettings? settings}) {
    return CustomPageRoute<T>(
      child: page,
      transitionType: TransitionType.slideUp,
      settings: settings,
    );
  }

  static Route<T> scaleTransition<T>(Widget page, {RouteSettings? settings}) {
    return CustomPageRoute<T>(
      child: page,
      transitionType: TransitionType.scale,
      curve: Curves.elasticOut,
      duration: const Duration(milliseconds: 500),
      settings: settings,
    );
  }

  static Route<T> fadeSlideTransition<T>(Widget page, {RouteSettings? settings}) {
    return CustomPageRoute<T>(
      child: page,
      transitionType: TransitionType.fadeSlide,
      settings: settings,
    );
  }
}

// Hero transition wrapper for smooth hero animations
class HeroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String heroTag;
  final Duration duration;

  HeroPageRoute({
    required this.child,
    required this.heroTag,
    this.duration = const Duration(milliseconds: 400),
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }
}

// Shared axis transition (Material Design)
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final SharedAxisTransitionType transitionType;
  final Duration duration;

  SharedAxisPageRoute({
    required this.child,
    this.transitionType = SharedAxisTransitionType.horizontal,
    this.duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    );

    final curvedSecondaryAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOut,
    );

    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-1.0, 0.0),
            ).animate(curvedSecondaryAnimation),
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 1.0,
                  end: 0.0,
                ).animate(curvedSecondaryAnimation),
                child: child,
              ),
            ),
          ),
        );

      case SharedAxisTransitionType.vertical:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0.0, -1.0),
            ).animate(curvedSecondaryAnimation),
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          ),
        );

      case SharedAxisTransitionType.scaled:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
    }
  }
}

enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

// Navigation helper with transitions
class NavigationHelper {
  static Future<T?> pushWithTransition<T>(
    BuildContext context,
    Widget page, {
    TransitionType transition = TransitionType.fadeSlide,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.push<T>(
      context,
      CustomPageRoute<T>(
        child: page,
        transitionType: transition,
        duration: duration,
        curve: curve,
      ),
    );
  }

  static Future<T?> pushReplacementWithTransition<T>(
    BuildContext context,
    Widget page, {
    TransitionType transition = TransitionType.fadeSlide,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.pushReplacement<T, dynamic>(
      context,
      CustomPageRoute<T>(
        child: page,
        transitionType: transition,
        duration: duration,
        curve: curve,
      ),
    );
  }

  static Future<T?> pushAndRemoveUntilWithTransition<T>(
    BuildContext context,
    Widget page,
    bool Function(Route<dynamic>) predicate, {
    TransitionType transition = TransitionType.fadeSlide,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      CustomPageRoute<T>(
        child: page,
        transitionType: transition,
        duration: duration,
        curve: curve,
      ),
      predicate,
    );
  }
}

// Animated page wrapper for consistent animations
class AnimatedPage extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedPage({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedPage> createState() => _AnimatedPageState();
}

class _AnimatedPageState extends State<AnimatedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}