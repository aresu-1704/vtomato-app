import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Helper class for showing toast notifications with different styles
class ToastHelper {
  /// Show success toast (green)
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFF4CAF50),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show error toast (red)
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFFE53935),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show info toast (blue)
  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFF1976D2),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Show warning toast (orange)
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFFFB8C00),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
