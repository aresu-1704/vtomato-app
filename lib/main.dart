import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/service_locator.dart';

void main() {
  // Setup service locator for dependency injection
  setupServiceLocator();

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rà soát bệnh trên cây cà chua',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      home: const LoginScreen(),
    );
  }
}
