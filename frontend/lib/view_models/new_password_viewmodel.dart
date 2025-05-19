import 'package:flutter/cupertino.dart';
import 'package:tomato_detect_app/services/auth_service.dart';

class NewPasswordViewModel {
  String? passwordError;
  String? confirmPasswordError;

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  bool isLoading = false;

  bool validatePasswords(String password, String confirmPassword) {
    passwordError = null;
    confirmPasswordError = null;

    if (password.length < 8) {
      passwordError = "Mật khẩu phải có ít nhất 8 ký tự.";
    }

    if (password != confirmPassword) {
      confirmPasswordError = "Mật khẩu xác nhận không khớp.";
    }

    return passwordError == null && confirmPasswordError == null;
  }

  Future<bool> resetPassword(int userID, String password, Function onSetState) async {
    final authService = AuthService();

    isLoading = true;
    onSetState();

    bool? isSuccess = await authService.resetPassword(userID, password);

    isLoading = false;
    onSetState();

    return isSuccess ?? false;
  }
}