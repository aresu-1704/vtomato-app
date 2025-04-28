import 'package:tomato_detect_app/services/auth_service.dart';

class ForgotPasswordViewModel {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<int?> sendOTP(String email, Function onSetState) async {
    isLoading = true;
    onSetState();

    int? result =  await _authService.sendOTPtoemail(email);

    isLoading = false;
    onSetState();

    return result;
  }
}
