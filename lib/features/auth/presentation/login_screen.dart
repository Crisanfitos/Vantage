import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/api/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  
  DateTime? _selectedBirthDate;
  bool _isRegistering = false;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    final auth = ref.read(authServiceProvider);
    
    try {
      if (_isRegistering) {
        await auth.signUpWithEmail(
          _emailController.text.trim(), 
          _passwordController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          birthDate: _selectedBirthDate,
          jobTitle: _jobTitleController.text.trim(),
        );
      } else {
        await auth.signInWithEmail(
          _emailController.text.trim(), 
          _passwordController.text.trim()
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'VANTAGE',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu vida, bajo control contextual',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              
              if (_isRegistering) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Apellidos', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Puesto de trabajo / Profesión', 
                    prefixIcon: Icon(Icons.work_outline),
                    border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.cake_outlined),
                  label: Text(_selectedBirthDate == null 
                    ? 'Fecha de nacimiento' 
                    : 'Nacido el: ${DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email', 
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder()
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña', 
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder()
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_isRegistering ? 'CREAR MI CUENTA' : 'ENTRAR', 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isRegistering = !_isRegistering),
                child: Text(_isRegistering 
                  ? '¿Ya eres de los nuestros? Inicia sesión' 
                  : '¿Nuevo en Vantage? Regístrate aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
