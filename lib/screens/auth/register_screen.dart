import 'package:flutter/material.dart';
import 'package:vtomato_app/services/auth_service.dart';
import 'package:vtomato_app/utils/toast_helper.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/modern_loading_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp phoneRegex = RegExp(r'^(0|\+84)[0-9]{9,10}$');

  bool isLoading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.register(
        emailController.text.trim(),
        phoneController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;

      ToastHelper.showSuccess(context, 'Đăng ký thành công!');
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (errorMsg.startsWith("Exception: ")) {
        errorMsg = errorMsg.substring(11);
      }
      ToastHelper.showError(context, errorMsg);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 58),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ZoomIn(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFDF6EC),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(35),
                    child: Image.asset(
                      'assets/images/tomato_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ĐĂNG KÝ TÀI KHOẢN',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Số điện thoại
                FadeInLeft(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: _buildTextFormField(
                    controller: phoneController,
                    hintText: 'Số điện thoại',
                    icon: Icons.phone,
                    focusNode: _phoneFocus,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Số điện thoại không được để trống';
                      if (!phoneRegex.hasMatch(value))
                        return 'Số điện thoại không hợp lệ';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Email
                FadeInRight(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 400),
                  child: _buildTextFormField(
                    controller: emailController,
                    hintText: 'Email',
                    icon: Icons.email,
                    focusNode: _emailFocus,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Email không được để trống';
                      if (!emailRegex.hasMatch(value))
                        return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Mật khẩu
                FadeInLeft(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 500),
                  child: _buildTextFormField(
                    controller: passwordController,
                    hintText: 'Mật khẩu',
                    icon: Icons.lock,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    focusNode: _passwordFocus,
                    toggleObscure: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Mật khẩu không được để trống';
                      if (value.length < 8) return 'Mật khẩu phải từ 8 ký tự';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Xác nhận mật khẩu
                FadeInRight(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 600),
                  child: _buildTextFormField(
                    controller: confirmPasswordController,
                    hintText: 'Xác nhận mật khẩu',
                    icon: Icons.lock,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    focusNode: _confirmPasswordFocus,
                    toggleObscure: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Vui lòng xác nhận mật khẩu';
                      if (value != passwordController.text)
                        return 'Mật khẩu không khớp';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 26),

                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 700),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () => {
                                FocusScope.of(context).unfocus(),
                                _register(),
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      child:
                          isLoading
                              ? const ButtonLoadingIndicator()
                              : const Text(
                                'ĐĂNG KÝ',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                FadeIn(
                  delay: const Duration(milliseconds: 800),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Đã có tài khoản ?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002F21),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    required FocusNode focusNode,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(focusNode.hasFocus ? 1.02 : 1.0),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            focusNode: focusNode,
            cursorColor: Colors.green.shade700,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              hintText: hintText,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.green.shade700),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.green.shade700, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: toggleObscure,
                      )
                      : null,
            ),
          ),
        );
      },
    );
  }
}
