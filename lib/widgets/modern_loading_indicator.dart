import 'package:flutter/material.dart';

/// Modern full-screen loading indicator with pulsing icon
class ModernLoadingIndicator extends StatefulWidget {
  final String? message;
  final Color? color;
  final IconData? icon;

  const ModernLoadingIndicator({Key? key, this.message, this.color, this.icon})
    : super(key: key);

  @override
  State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing icon animation
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                widget.icon ?? Icons.biotech_rounded, // Microscope by default
                size: 80,
                color: widget.color ?? Colors.green[700],
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 24),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 16,
              color: widget.color ?? Colors.green[800],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Compact loading indicator for buttons with rotating refresh icon
class ButtonLoadingIndicator extends StatefulWidget {
  final Color? color;

  const ButtonLoadingIndicator({Key? key, this.color}) : super(key: key);

  @override
  State<ButtonLoadingIndicator> createState() => _ButtonLoadingIndicatorState();
}

class _ButtonLoadingIndicatorState extends State<ButtonLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: Icon(
              Icons.refresh,
              size: 20,
              color: widget.color ?? Colors.white,
            ),
          );
        },
      ),
    );
  }
}
