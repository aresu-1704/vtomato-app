import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vtomato_app/services/auth_service.dart';
import 'package:vtomato_app/utils/toast_helper.dart';
import 'login_screen.dart';
import 'forgot_password_screen.dart';
import 'new_password_screen.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/gradient_background.dart';

class VerifyOtpScreen extends StatefulWidget {
  final int userID;
  final String email;

  const VerifyOtpScreen({Key? key, required this.userID, required this.email})
    : super(key: key);

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final AuthService _authService = AuthService();
  final List<TextEditingController> otpControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(5, (_) => FocusNode());
  int secondsRemaining = 60;
  bool isResendEnabled = false;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    secondsRemaining = 60;
    isResendEnabled = false;
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  void stopCountdown() {
    countdownTimer?.cancel();
  }

  Future<void> _verifyOTP() async {
    String otp = otpControllers.map((c) => c.text).join();

    if (otp.length != 5) {
      ToastHelper.showError(context, 'Vui lòng nhập đầy đủ 5 chữ số OTP.');
      return;
    }

    try {
      await _authService.verifyOTP(widget.userID, int.parse(otp));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(userID: widget.userID),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (errorMsg.startsWith("Exception: ")) {
        errorMsg = errorMsg.substring(11);
      }
      ToastHelper.showError(context, errorMsg);
    }
  }

  Future<void> _resendOTP(String email) async {
    try {
      await _authService.sendOTPtoemail(email);
      if (!mounted) return;

      startCountdown();
      ToastHelper.showSuccess(context, 'Mã OTP đã được gửi lại.');
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (errorMsg.startsWith("Exception: ")) {
        errorMsg = errorMsg.substring(11);
      }
      ToastHelper.showError(context, errorMsg);
    }
  }

  @override
  void dispose() {
    stopCountdown();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
              ),
              centerTitle: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BounceInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFDF6EC),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mark_email_read,
                            size: 80,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Nhập mã xác minh",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeIn(
                        delay: const Duration(milliseconds: 400),
                        child: const Text(
                          "Nhập vào mã OTP gồm 5 chữ số đã gửi đến\nEmail bạn",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ZoomIn(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => AnimatedBuilder(
                              animation: otpFocusNodes[index],
                              builder: (context, child) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  transform:
                                      Matrix4.identity()..scale(
                                        otpFocusNodes[index].hasFocus
                                            ? 1.1
                                            : 1.0,
                                      ),
                                  width: 50,
                                  height: 60,
                                  child: TextField(
                                    controller: otpControllers[index],
                                    focusNode: otpFocusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    cursorColor: Colors.green.shade700,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: "",
                                      filled: true,
                                      fillColor:
                                          otpFocusNodes[index].hasFocus
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.green.shade700,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.length == 1 &&
                                          index < otpControllers.length - 1) {
                                        FocusScope.of(context).nextFocus();
                                      } else if (value.isEmpty && index > 0) {
                                        FocusScope.of(context).previousFocus();
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      FadeIn(
                        delay: const Duration(milliseconds: 700),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Chưa nhận được OTP?",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed:
                                  isResendEnabled
                                      ? () => _resendOTP(widget.email)
                                      : null,
                              child: Text(
                                isResendEnabled
                                    ? "Gửi lại"
                                    : "Gửi lại sau ${secondsRemaining}s",
                                style: TextStyle(
                                  color:
                                      isResendEnabled
                                          ? const Color(0xFF002F21)
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 800),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 41,
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                "Hủy bỏ",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _verifyOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 33,
                                  vertical: 14,
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                "Xác minh",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
