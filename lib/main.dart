import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart'; // ← AJOUTEZ CETTE LIGNE

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parapharmacie S&A', // ← CHANGÉ
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // ← AJOUTEZ CETTE LIGNE
      home: const LoginScreen(),
    );
  }
}
