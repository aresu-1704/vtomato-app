import 'package:flutter/material.dart';

/// Custom notification overlay that appears at the top of the screen
/// Provides beautiful, non-conflicting notifications with smooth animations
class AppNotification {
  /// Show success notification (green)
  static void showSuccess(BuildContext context, String message) {
    _showNotification(
      context,
      message,
      Icons.check_circle_rounded,
      Colors.green.shade600,
      Colors.green.shade50,
    );
  }

  /// Show error notification (red)
  static void showError(BuildContext context, String message) {
    _showNotification(
      context,
      message,
      Icons.error_rounded,
      Colors.red.shade600,
      Colors.red.shade50,
    );
  }

  /// Show info notification (blue)
  static void showInfo(BuildContext context, String message) {
    _showNotification(
      context,
      message,
      Icons.info_rounded,
      Colors.blue.shade600,
      Colors.blue.shade50,
    );
  }

  /// Show warning notification (orange)
  static void showWarning(BuildContext context, String message) {
    _showNotification(
      context,
      message,
      Icons.warning_rounded,
      Colors.orange.shade700,
      Colors.orange.shade50,
    );
  }

  static void _showNotification(
    BuildContext context,
    String message,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
  ) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => _NotificationWidget(
            message: message,
            icon: icon,
            iconColor: iconColor,
            backgroundColor: backgroundColor,
          ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

/// Internal widget for displaying the notification
class _NotificationWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _NotificationWidget({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Start reverse animation after 2.6 seconds
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.iconColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.iconColor.withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: widget.iconColor.withOpacity(0.95),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
