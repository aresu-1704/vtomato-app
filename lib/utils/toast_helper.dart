import 'package:flutter/material.dart';
import 'package:vtomato_app/widgets/app_notification.dart';

/// Helper class for showing beautiful top notifications
/// Uses custom AppNotification overlay instead of SnackBar to avoid conflicts
class ToastHelper {
  /// Show success notification (green, top position)
  static void showSuccess(BuildContext context, String message) {
    AppNotification.showSuccess(context, message);
  }

  /// Show error notification (red, top position)
  static void showError(BuildContext context, String message) {
    AppNotification.showError(context, message);
  }

  /// Show info notification (blue, top position)
  static void showInfo(BuildContext context, String message) {
    AppNotification.showInfo(context, message);
  }

  /// Show warning notification (orange, top position)
  static void showWarning(BuildContext context, String message) {
    AppNotification.showWarning(context, message);
  }
}
