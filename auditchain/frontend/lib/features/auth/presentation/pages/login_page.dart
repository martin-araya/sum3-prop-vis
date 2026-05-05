import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:auditchain/app/router/app_router.dart';
import 'package:auditchain/app/theme/app_colors.dart';

/// Página de login de AuditChain.
///
/// Layout responsivo de dos columnas:
///  - Izquierda (420 px, fondo navy #0A2540): branding + bullets de propuesta de valor.
///  - Derecha (flex, fondo blanco): formulario de credenciales.
///
/// En viewports angostos (< 880 px) se colapsa a una sola columna y se oculta el panel
/// de branding para priorizar el formulario.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _navy = Color(0xFF0A2540);
  static const Color _primary = Color(0xFF1E3A8A);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate400 = Color(0xFF94A3B8);
  static const Color _border = Color(0xFFE2E8F0);

  late final TextEditingController _emailCtrl =
      TextEditingController(text: 'admin@auditchain.cl');
  late final TextEditingController _passwordCtrl =
      TextEditingController(text: '00000000'); // 8 chars → render como ●●●●●●●●

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    isAuthenticated = true;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 880;

          if (!isWide) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _RightPanel(
                      emailCtrl: _emailCtrl,
                      passwordCtrl: _passwordCtrl,
                      onSubmit: _submit,
                      primary: _primary,
                      slate500: _slate500,
                      slate400: _slate400,
                      border: _border,
                    ),
                  ),
                ),
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 420,
                child: _LeftPanel(navy: _navy),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 64, vertical: 48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _RightPanel(
                        emailCtrl: _emailCtrl,
                        passwordCtrl: _passwordCtrl,
                        onSubmit: _submit,
                        primary: _primary,
                        slate500: _slate500,
                        slate400: _slate400,
                        border: _border,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── PANEL IZQUIERDO ─────────────────────────────────────────────────────────

class _LeftPanel extends StatelessWidget {
  const _LeftPanel({required this.navy});

  final Color navy;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: navy,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Logo
          Row(
            children: const <Widget>[
              Icon(Icons.verified_outlined, color: AppColors.accent500, size: 32),
              SizedBox(width: 10),
              Text(
                'AuditChain',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tagline
          const Text(
            'Sistema de auditoría para redes de franquicias',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          // Bullets
          const _Bullet(text: 'Monitoreo en tiempo real de sucursales'),
          const SizedBox(height: 14),
          const _Bullet(text: 'Reportes automáticos por región'),
          const SizedBox(height: 14),
          const _Bullet(text: 'Gestión de auditores de campo'),
          const Spacer(),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(Icons.check_circle, color: AppColors.accent500, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── PANEL DERECHO ───────────────────────────────────────────────────────────

class _RightPanel extends StatelessWidget {
  const _RightPanel({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.onSubmit,
    required this.primary,
    required this.slate500,
    required this.slate400,
    required this.border,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final VoidCallback onSubmit;
  final Color primary;
  final Color slate500;
  final Color slate400;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text(
          'Iniciar sesión',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ingresa tus credenciales para continuar',
          style: TextStyle(fontSize: 14, color: slate500, height: 1.4),
        ),
        const SizedBox(height: 28),

        // Email
        _FieldLabel(text: 'Email', color: slate500),
        const SizedBox(height: 6),
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: _decoration(border: border, primary: primary),
        ),
        const SizedBox(height: 16),

        // Password
        _FieldLabel(text: 'Contraseña', color: slate500),
        const SizedBox(height: 6),
        TextField(
          controller: passwordCtrl,
          obscureText: true,
          decoration: _decoration(border: border, primary: primary),
        ),
        const SizedBox(height: 24),

        // Botón
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Entrar'),
          ),
        ),
        const SizedBox(height: 12),

        // Nota de demostración
        Center(
          child: Text(
            'Acceso de demostración — datos simulados',
            style: TextStyle(
              fontSize: 11,
              color: slate400,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration({required Color border, required Color primary}) {
    return InputDecoration(
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
      ),
    );
  }
}
