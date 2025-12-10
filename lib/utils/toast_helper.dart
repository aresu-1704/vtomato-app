import 'package:flutter/material.dart';

/// Helper class for showing beautiful toast notifications using SnackBar
class ToastHelper {
  /// Show success toast (green)
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, Icons.check_circle, Colors.green.shade600);
  }

  /// Show error toast (red)
  static void showError(BuildContext context, String message) {
    _showToast(context, message, Icons.error_outline, Colors.red.shade600);
  }

  /// Show info toast (blue)
  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, Icons.info_outline, Colors.blue.shade600);
  }

  /// Show warning toast (orange)
  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message,
      Icons.warning_amber_rounded,
      Colors.orange.shade800,
    );
  }

  static void _showToast(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    // Remove current SnackBar if any to avoid stacking delay
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
