import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/login_screen.dart';
import 'shared/widgets/bottom_nav.dart';

void main() => runApp(const AuditChainMobileApp());

class AuditChainMobileApp extends StatelessWidget {
  const AuditChainMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuditChain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    AuthClient.isLoggedIn().then((ok) {
      if (mounted) setState(() { _loggedIn = ok; _checking = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A2540),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4))),
      );
    }
    return _loggedIn ? const AuditorBottomNav() : const LoginScreen();
  }
}
