import 'package:flutter/material.dart';
import 'package:tomato_detect_app/view_models/forgot_password_viewmodel.dart';
import 'login_screen.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final ForgotPasswordViewModel _viewModel = ForgotPasswordViewModel();
  final _formKey = GlobalKey<FormState>();

  Future<void> _sendOTPToEmail() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đang gửi OTP đến Email của bạn...')
        )
    );
    
    final result = await _viewModel.sendOTP(
        emailController.text.trim(),
        _onSetState
    );

    if (!mounted) return;

    switch (result) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(email: emailController.text.trim()),
          ),
        );
        break;
      case 0:
        _showSnackBar('Tài khoản không tồn tại.');
        break;
      default:
        _showSnackBar('Vui lòng thử lại sau.');
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSetState(){
    setState(() { });
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
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        title: Text(
          'QUÊN MẬT KHẨU',
          style: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Nhập địa chỉ Email của bạn để nhận mã OTP khôi phục mật khẩu",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.green.shade700,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                  ),
                  hintText: "Địa chỉ Email",
                  suffixIcon: const Icon(Icons.check, color: Colors.green),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập Email';
                  }
                  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                  if (!regex.hasMatch(value.trim())) {
                    return 'Vui lòng nhập địa chỉ email hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _viewModel.isLoading ? null : _sendOTPToEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _viewModel.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                    "NHẬN MÃ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
