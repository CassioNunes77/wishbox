import 'package:flutter/material.dart';

/// Animações estilo Duolingo - divertidas e suaves
class DuolingoAnimations {
  // Animação de bounce ao tocar (estilo Duolingo)
  static Widget bounceOnTap({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.95,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return _BounceWidget(
      onTap: onTap,
      scale: scale,
      duration: duration,
      child: child,
    );
  }

  // Animação de fade in com slide (entrada suave)
  static Widget fadeInSlide({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOut,
    Offset offset = const Offset(0, 20),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: offset * (1 - value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Animação de scale (zoom) estilo Duolingo
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Animação de pulso (para elementos importantes)
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.1),
      duration: duration,
      curve: Curves.easeInOut,
      onEnd: () {
        // Reinicia a animação
      },
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Animação de shake (para erros)
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        final shake = (value * 10 * (1 - value));
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _BounceWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;

  const _BounceWidget({
    required this.child,
    required this.onTap,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<_BounceWidget> createState() => _BounceWidgetState();
}

class _BounceWidgetState extends State<_BounceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}



