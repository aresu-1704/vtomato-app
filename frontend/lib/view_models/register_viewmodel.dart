import 'package:flutter/material.dart';
import 'package:tomato_detect_app/services/auth_service.dart';

class RegisterViewModel {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp phoneRegex = RegExp(r'^(0|\+84)[0-9]{9,10}$');

  bool isValidForm() {
    if (phoneController.text.isEmpty || !phoneRegex.hasMatch(phoneController.text)) {
      return false;
    }

    if (emailController.text.isEmpty || !emailRegex.hasMatch(emailController.text)) {
      return false;
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      return false;
    }

    if (confirmPasswordController.text != passwordController.text) {
      return false;
    }

    return true;
  }

  Future<int?> registerNewAccount(Function(bool) onLoadingChange) async {
    if (isValidForm()) {
      onLoadingChange(true);

      final email = emailController.text.trim();
      final password = passwordController.text;
      final phoneNumber = phoneController.text;

      final authService = AuthService();
      final error = await authService.register(email, phoneNumber, password);

      if (error == null) {
        return 1;
      }
      else {
        return 0;
      }
    }
  }
}
