import 'package:flutter/material.dart';
import 'package:tomato_detect_app/services/auth_service.dart';
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

  String? _passwordError;
  String? _confirmError;

  bool _isLoading = false;

  Future<void> _validateAndSubmit() async {
    FocusScope.of(context).unfocus();

    String password = _passwordController.text;
    String confirm = _confirmPasswordController.text;

    setState(() {
      _passwordError = null;
      _confirmError = null;
    });

    if (password.length < 8) {
      setState(() {
        _passwordError = "Mật khẩu phải có ít nhất 8 ký tự.";
      });
    }

    if (password != confirm) {
      setState(() {
        _confirmError = "Mật khẩu xác nhận không khớp.";
      });
    }

    if (_passwordError == null && _confirmError == null) {
      setState(() {
        _isLoading = true;
      });

      final _authService = AuthService();
      bool? isResetSuccess = await _authService.resetPassword(widget.email, password);

      setState(() {
        _isLoading = false;
      });

      if (isResetSuccess!) {
        Navigator.pop(
          context
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Khôi phục mật khẩu thất bại, vui lòng thử lại!')),
        );
      }
    }
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
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              cursorColor: _passwordError != null ? Colors.red : Colors.green.shade700,
              decoration: InputDecoration(
                labelText: "MẬT KHẨU MỚI",
                labelStyle: TextStyle(
                  color: _passwordError != null ? Colors.red : Colors.green.shade700,
                ),
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: _passwordError != null ? Colors.red : Colors.green.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _passwordError != null ? Colors.red : Colors.green.shade700,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _passwordError != null ? Colors.red : Colors.green.shade700,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Xác nhận mật khẩu
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              cursorColor: _confirmError != null ? Colors.red : Colors.green.shade700,
              decoration: InputDecoration(
                labelText: "XÁC NHẬN MẬT KHẨU",
                labelStyle: TextStyle(
                  color: _confirmError != null ? Colors.red : Colors.green.shade700,
                ),
                errorText: _confirmError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: _confirmError != null ? Colors.red : Colors.green.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _confirmError != null ? Colors.red : Colors.green.shade700,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _confirmError != null ? Colors.red : Colors.green.shade700,
                    width: 2,
                  ),
                ),
              ),
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
