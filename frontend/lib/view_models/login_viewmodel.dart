import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginViewModel {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('email') ?? '';
    passwordController.text = prefs.getString('password') ?? '';
  }

  Future<int?> login(Function onSetState) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    isLoading = true;
    onSetState();

    final authService = AuthService();
    final userId = await authService.login(email, password);

    if (userId != null && userId > 0) {
      await _saveUserData(email, password);
    }

    return userId;
  }

  Future<void> _saveUserData(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  void setState(bool isLoading, Function onSetState){
    this.isLoading = isLoading;
    onSetState();
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
