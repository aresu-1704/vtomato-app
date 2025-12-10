import 'package:flutter/material.dart';
import 'package:tomato_detect_app/services/auth_service.dart';
import 'package:tomato_detect_app/utils/toast_helper.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final int userID;

  const NewPasswordScreen({Key? key, required this.userID}) : super(key: key);

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? passwordError;
  String? confirmPasswordError;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool validatePasswords(String password, String confirmPassword) {
    setState(() {
      passwordError = null;
      confirmPasswordError = null;
    });

    bool isValid = true;
    if (password.length < 8) {
      setState(() {
        passwordError = "Mật khẩu phải có ít nhất 8 ký tự.";
      });
      isValid = false;
    }

    if (password != confirmPassword) {
      setState(() {
        confirmPasswordError = "Mật khẩu xác nhận không khớp.";
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> _validateAndSubmit() async {
    FocusScope.of(context).unfocus();

    String password = passwordController.text;
    String confirm = confirmPasswordController.text;

    if (validatePasswords(password, confirm)) {
      setState(() {
        isLoading = true;
      });

      try {
        final authService = AuthService();
        await authService.resetPassword(widget.userID, password);

        if (!mounted) return;

        ToastHelper.showSuccess(context, 'Khôi phục mật khẩu thành công!');
        Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          String errorMsg = e.toString();
          if (errorMsg.startsWith("Exception: ")) {
            errorMsg = errorMsg.substring(11);
          }
          ToastHelper.showError(context, errorMsg);
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
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
          style: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
          ),
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
              controller: passwordController,
              label: "MẬT KHẨU MỚI",
              errorText: passwordError,
              obscureText: obscurePassword,
              toggleObscure: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
            const SizedBox(height: 16),
            // Xác nhận mật khẩu
            _buildTextField(
              controller: confirmPasswordController,
              label: "XÁC NHẬN MẬT KHẨU",
              errorText: confirmPasswordError,
              obscureText: obscureConfirm,
              toggleObscure: () {
                setState(() {
                  obscureConfirm = !obscureConfirm;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: SizedBox(
                height: 28,
                child: Center(
                  child:
                      isLoading
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
                              fontSize: 20,
                            ),
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
