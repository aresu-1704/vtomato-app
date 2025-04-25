import 'package:flutter/material.dart';
import 'package:tomato_detect_app/view_models/register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterViewModel _viewModel = RegisterViewModel();
  bool _isLoading = false;

  void _onLoadingChange(bool loading) {
    setState(() => _isLoading = loading);
  }

  Future<void> _register() async {
    final result = await _viewModel.registerNewAccount(_onLoadingChange);

    if (result! == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đăng ký thành công!')
        )
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(
          context,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email đã tồn tại.')
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF6EE),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 58),
        child: Form(
          child: Column(
            children: [
              Image.asset('assets/images/tomato_icon.png', width: 200, height: 200),
              const SizedBox(height: 15),
              Text(
                'ĐĂNG KÝ TÀI KHOẢN',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800])
              ),
              const SizedBox(height: 18),

              // Số điện thoại
              _buildTextFormField(
                controller: _viewModel.phoneController,
                hintText: 'Số điện thoại',
                icon: Icons.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Số điện thoại không được để trống';
                  if (!_viewModel.phoneRegex.hasMatch(value))
                    return 'Số điện thoại không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Email
              _buildTextFormField(
                controller: _viewModel.emailController,
                hintText: 'Email',
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Email không được để trống';
                  if (!_viewModel.emailRegex.hasMatch(value)) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Mật khẩu
              _buildTextFormField(
                controller: _viewModel.passwordController,
                hintText: 'Mật khẩu',
                icon: Icons.lock,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Mật khẩu không được để trống';
                  if (value.length < 8) return 'Mật khẩu phải từ 8 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Xác nhận mật khẩu
              _buildTextFormField(
                controller: _viewModel.confirmPasswordController,
                hintText: 'Xác nhận mật khẩu',
                icon: Icons.lock,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                  if (value != _viewModel.passwordController.text) return 'Mật khẩu không khớp';
                  return null;
                },
              ),
              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                    ? null
                    : () => {
                      FocusScope.of(context).unfocus(),
                      _register()
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      'ĐĂNG KÝ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản ?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child: const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF002F21))),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
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
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
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
      ),
    );
  }
}
