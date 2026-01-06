import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:campusconnect/core/services/firebase_service.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(const CampusConnectApp());
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusConnect',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
