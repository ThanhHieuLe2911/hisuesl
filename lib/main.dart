import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:hisuesl/features/auth/screens/login_screen.dart';
import 'package:hisuesl/features/home/screens/home_screen.dart';
import 'package:hisuesl/features/auth/services/auth_service.dart';
import 'package:hisuesl/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}
  
  await Firebase.initializeApp();
  await NotificationService().init();

  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  if (apiKey.isNotEmpty) {
    Gemini.init(apiKey: apiKey);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final user = AuthService().currentUser;
      if (mounted) {
        setState(() {
          _isLoggedIn = user != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HisuESL',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: _isLoading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _isLoggedIn
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}