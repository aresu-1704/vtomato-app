import 'package:tomato_detect_app/services/auth_service.dart';

class NewPasswordViewModel {
  String? passwordError;
  String? confirmPasswordError;

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

  Future<bool> resetPassword(String email, String password) async {
    final authService = AuthService();
    bool? isSuccess = await authService.resetPassword(email, password);
    return isSuccess ?? false;
  }
}