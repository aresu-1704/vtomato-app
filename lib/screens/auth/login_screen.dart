import 'package:flutter/material.dart';
import 'package:tomato_detect_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../home/camera_screen.dart';
import 'package:tomato_detect_app/utils/toast_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<String> _login() async {
    setState(() => _isLoading = true);
    final authService = AuthService();
    return await authService.login(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 90),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                'assets/images/tomato_icon.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              Text(
                'ỨNG DỤNG NHẬN DIỆN BỆNH TRÊN LÁ CÀ CHUA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 32),

              _buildTextField(
                controller: _emailController,
                hint: 'Địa chỉ Email',
                icon: Icons.email_outlined,
                validatorMsg: 'Email không được để trống',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _passwordController,
                hint: 'Mật khẩu',
                icon: Icons.lock_outline,
                obscure: true,
                validatorMsg: 'Mật khẩu không được để trống',
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                  child: const Text(
                    'Quên mật khẩu ?',
                    style: TextStyle(color: Color(0xFF002F21)),
                  ),
                ),
              ),

              const SizedBox(height: 1),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              FocusScope.of(context).unfocus();

                              try {
                                final userId = await _login();

                                if (!mounted) return;

                                // Success logic
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                  'email',
                                  _emailController.text,
                                );
                                await prefs.setString(
                                  'password',
                                  _passwordController.text,
                                );

                                _showSnackBar('Đăng nhập thành công');
                                await Future.delayed(
                                  const Duration(seconds: 1),
                                );
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            CameraScreen(UserId: userId),
                                  ),
                                );
                              } catch (e) {
                                if (mounted) {
                                  // Clean up the error message (remove "Exception: ")
                                  String errorMsg = e.toString();
                                  if (errorMsg.startsWith("Exception: ")) {
                                    errorMsg = errorMsg.substring(11);
                                  }
                                  _showSnackBar(errorMsg);
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Không có tài khoản ?'),
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterScreen(),
                                ),
                              );
                            },
                    child: const Text(
                      'Đăng ký',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002F21),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String text) {
    // Determine type based on text content (simple heuristic)
    if (text.contains('thành công')) {
      ToastHelper.showSuccess(context, text);
    } else if (text.contains('Lỗi') ||
        text.contains('Sai') ||
        text.contains('Không thể')) {
      ToastHelper.showError(context, text);
    } else {
      ToastHelper.showInfo(context, text);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    required String validatorMsg,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      cursorColor: Colors.green[700],
      validator:
          (value) =>
              (value == null || value.trim().isEmpty) ? validatorMsg : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: _buildBorder(),
        focusedBorder: _buildBorder(width: 2),
        errorBorder: _buildBorder(color: Colors.red),
        focusedErrorBorder: _buildBorder(color: Colors.red, width: 2),
      ),
    );
  }

  OutlineInputBorder _buildBorder({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: color ?? Colors.green.shade700,
        width: width,
      ),
    );
  }
}
