import 'package:tomato_detect_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class VerifyOtpViewModel {
  final AuthService _authService = AuthService();
  final List<TextEditingController> otpControllers = List.generate(5, (_) => TextEditingController());
  int secondsRemaining = 60;
  bool isResendEnabled = false;
  Timer? countdownTimer;

  void startCountdown(Function updateUI) {
    secondsRemaining = 60;
    isResendEnabled = false;
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        updateUI();
      } else {
        isResendEnabled = true;
        updateUI();
        timer.cancel();
      }
    });
  }

  Future<int?> verifyOTP(int userID) async {
    String otp = otpControllers.map((c) => c.text).join();
    if (otp.length != 5) {
      return -1;
    }
    return await _authService.verifyOTP(userID, int.parse(otp));
  }

  Future<int?> resendOTP(String email) async {
    final result = await _authService.sendOTPtoemail(email);
    if (result == 1) {
      startCountdown(() {});
    }
    return result;
  }

  void dispose() {
    countdownTimer?.cancel();
  }
}

