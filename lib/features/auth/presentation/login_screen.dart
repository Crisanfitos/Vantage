import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;

  Future<void> _submit() async {
    final auth = ref.read(authServiceProvider);
    try {
      if (_isRegistering) {
        await auth.signUpWithEmail(_emailController.text, _passwordController.text);
      } else {
        await auth.signInWithEmail(_emailController.text, _passwordController.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: MainAxisAlignment.stretch,
          children: [
            Text(
              'VANTAGE',
              textAlign: MainAxisAlignment.center,
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: Text(_isRegistering ? 'Crear Cuenta' : 'Iniciar Sesión'),
            ),
            TextButton(
              onPressed: () => setState(() => _isRegistering = !_isRegistering),
              child: Text(_isRegistering ? '¿Ya tienes cuenta? Entra' : '¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
