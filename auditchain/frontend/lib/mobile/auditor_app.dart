import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'auditor_home_screen.dart';

class AuditorApp extends StatefulWidget {
  const AuditorApp({super.key});

  @override
  State<AuditorApp> createState() => _AuditorAppState();
}

class _AuditorAppState extends State<AuditorApp> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final ok = await AuthService.isLoggedIn();
    setState(() {
      _loggedIn = ok;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A2540),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
        ),
      );
    }
    if (!_loggedIn) {
      return LoginScreen(onLogin: () => setState(() => _loggedIn = true));
    }
    return AuditorHomeScreen(onLogout: () => setState(() => _loggedIn = false));
  }
}
