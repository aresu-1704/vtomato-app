import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tomato_detect_app/view_models/verify_OTP_viewmodel.dart';
import 'login_screen.dart';
import 'forgot_password_screen.dart';
import 'new_password_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final int userID;
  final String email;

  const VerifyOtpScreen({Key? key, required this.userID, required this.email}) : super(key: key);

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  late VerifyOtpViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VerifyOtpViewModel();
    _viewModel.startCountdown(_updateUI);
  }

  void _updateUI() {
    setState(() {});
  }

  Future<void> _verifyOTP() async {
    String otp = _viewModel.otpControllers.map((c) => c.text).join();

    if (otp.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ 5 chữ số OTP.')),
      );
      return;
    }

    final result = await _viewModel.verifyOTP(widget.userID);

    if (result == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(userID: widget.userID),
        ),
      );
    } else if (result == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP không đúng.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi, vui lòng thử lại.')),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
            );
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_read, size: 100, color: Colors.green[700]),
              const SizedBox(height: 24),
              Text(
                "Nhập mã xác minh",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Nhập vào mã OTP gồm 5 chữ số đã gửi đến\nEmail bạn",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _viewModel.otpControllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      cursorColor: Colors.green.shade700,
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < _viewModel.otpControllers.length - 1) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa nhận được OTP?"),
                  TextButton(
                    onPressed: _viewModel.isResendEnabled
                      ? () async {
                        final resend = await _viewModel.resendOTP(widget.email);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              resend == 1 ? 'Mã OTP đã được gửi lại.' : 'Gửi lại thất bại.',
                            ),
                          ),
                        );
                      }
                      : null,
                        child: Text(
                          _viewModel.isResendEnabled
                              ? "Gửi lại"
                              : "Gửi lại sau ${_viewModel.secondsRemaining}s",
                          style: TextStyle(
                            color: _viewModel.isResendEnabled
                                ? const Color(0xFF002F21)
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 15),
              Row(
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
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(horizontal: 41, vertical: 14),
                    ),
                    child: const Text("Hủy bỏ", style: TextStyle(color: Color(0xFF002F21))),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 14),
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
            ],
          ),
        ),
      ),
    );
  }
}
