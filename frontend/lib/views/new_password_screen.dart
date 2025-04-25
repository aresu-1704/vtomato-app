import 'package:flutter/material.dart';
import 'package:tomato_detect_app/view_models/new_password_viewmodel.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;

  const NewPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;
  final _viewModel = NewPasswordViewModel();

  Future<void> _validateAndSubmit() async {
    FocusScope.of(context).unfocus();

    String password = _passwordController.text;
    String confirm = _confirmPasswordController.text;

    if (_viewModel.validatePasswords(password, confirm)) {
      setState(() {
        _isLoading = true;
      });

      bool isResetSuccess = await _viewModel.resetPassword(widget.email, password);

      setState(() {
        _isLoading = false;
      });

      if (isResetSuccess) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Khôi phục mật khẩu thất bại, vui lòng thử lại!')),
        );
      }
    } else {
      setState(() {});
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? errorText,
    required bool obscureText,
    required void Function() toggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: errorText != null ? Colors.red : Colors.green.shade700,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: errorText != null ? Colors.red : Colors.green.shade700,
        ),
        errorText: errorText,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: errorText != null ? Colors.red : Colors.green.shade700,
          ),
          onPressed: toggleObscure,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: errorText != null ? Colors.red : Colors.green.shade700,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: errorText != null ? Colors.red : Colors.green.shade700,
            width: 2,
          ),
        ),
      ),
    );
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
          "TẠO MẬT KHẨU MỚI",
          style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Vui lòng tạo mật khẩu mới để khôi phục tài khoản của bạn",
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Mật khẩu mới
            _buildTextField(
              controller: _passwordController,
              label: "MẬT KHẨU MỚI",
              errorText: _viewModel.passwordError,
              obscureText: _obscurePassword,
              toggleObscure: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            const SizedBox(height: 16),
            // Xác nhận mật khẩu
            _buildTextField(
              controller: _confirmPasswordController,
              label: "XÁC NHẬN MẬT KHẨU",
              errorText: _viewModel.confirmPasswordError,
              obscureText: _obscureConfirm,
              toggleObscure: () {
                setState(() {
                  _obscureConfirm = !_obscureConfirm;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                "Khôi phục mật khẩu",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
