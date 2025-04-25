import 'package:tomato_detect_app/services/auth_service.dart';

class ForgotPasswordViewModel {
  final AuthService _authService = AuthService();

  Future<int?> sendOTP(String email) async {
    return await _authService.sendOTPtoemail(email);
  }
}
