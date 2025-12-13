import 'package:flutter/material.dart';
import 'package:vtomato_app/services/auth_service.dart';
import 'package:vtomato_app/utils/toast_helper.dart';
import 'login_screen.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_loading_indicator.dart';

class NewPasswordScreen extends StatefulWidget {
  final int userID;

  const NewPasswordScreen({Key? key, required this.userID}) : super(key: key);

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  String? passwordError;
  String? confirmPasswordError;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
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
    required FocusNode focusNode,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(focusNode.hasFocus ? 1.02 : 1.0),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
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
              filled: true,
              fillColor:
                  focusNode.hasFocus
                      ? Colors.green.withOpacity(0.05)
                      : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
          ),
        );
      },
    );
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
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
              title: FadeIn(
                child: const Text(
                  "TẠO MẬT KHẨU MỚI",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              centerTitle: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: const Text(
                        "Vui lòng tạo mật khẩu mới để khôi phục tài khoản của bạn",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Mật khẩu mới
                    FadeInLeft(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 200),
                      child: _buildTextField(
                        controller: passwordController,
                        label: "MẬT KHẨU MỚI",
                        errorText: passwordError,
                        obscureText: obscurePassword,
                        focusNode: _passwordFocus,
                        toggleObscure: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Xác nhận mật khẩu
                    FadeInRight(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 400),
                      child: _buildTextField(
                        controller: confirmPasswordController,
                        label: "XÁC NHẬN MẬT KHẨU",
                        errorText: confirmPasswordError,
                        obscureText: obscureConfirm,
                        focusNode: _confirmPasswordFocus,
                        toggleObscure: () {
                          setState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _validateAndSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                        child: SizedBox(
                          height: 28,
                          child: Center(
                            child:
                                isLoading
                                    ? const ButtonLoadingIndicator()
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
