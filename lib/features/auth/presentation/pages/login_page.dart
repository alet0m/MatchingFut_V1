// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/auth_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _keepSession = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón de regreso
                IconButton(
                  onPressed: () => context.go('/welcome'),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 20),

                // Título
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3),

                const Text(
                      'Bienvenido de vuelta, jugador',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 800.ms)
                    .slideX(begin: -0.3),

                const SizedBox(height: 40),

                // Formulario
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Campo Email
                            TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'tu@email.com',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu email';
                                    }
                                    if (!RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    ).hasMatch(value)) {
                                      return 'Por favor ingresa un email válido';
                                    }
                                    return null;
                                  },
                                )
                                .animate(delay: 400.ms)
                                .fadeIn(duration: 800.ms)
                                .slideY(begin: 0.3),

                            const SizedBox(height: 20),

                            // Campo Contraseña
                            TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    hintText: 'Tu contraseña',
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu contraseña';
                                    }
                                    if (value.length < 6) {
                                      return 'La contraseña debe tener al menos 6 caracteres';
                                    }
                                    return null;
                                  },
                                )
                                .animate(delay: 600.ms)
                                .fadeIn(duration: 800.ms)
                                .slideY(begin: 0.3),

                            const SizedBox(height: 30),

                            // Opción de mantener sesión iniciada
                            Row(
                              children: [
                                Checkbox(
                                  value: _keepSession,
                                  onChanged: (value) {
                                    setState(() {
                                      _keepSession = value ?? false;
                                    });
                                  },
                                ),
                                const Text('Mantener sesión iniciada'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Botón de inicio de sesión
                            SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        _isLoading
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text(
                                              'INICIAR SESIÓN',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                  ),
                                )
                                .animate(delay: 800.ms)
                                .fadeIn(duration: 800.ms)
                                .slideY(begin: 0.3),

                            const SizedBox(height: 20),

                            // Link de contraseña olvidada
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Función próximamente disponible',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(color: Color(0xFF2E7D32)),
                              ),
                            ).animate(delay: 1000.ms).fadeIn(duration: 800.ms),
                          ],
                        ),
                      ),
                    )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 1000.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 30),

                // Link para registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        'Regístrate aquí',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 1200.ms).fadeIn(duration: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);

      final response = await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        keepSession: _keepSession, // Pasar preferencia
      );

      if (response.user != null && mounted) {
        // Guardar preferencia local si se seleccionó "mantener sesión"
        if (_keepSession) {
          // Implementar guardado en SharedPreferences para persistencia
          await authService.saveSessionLocally(response);
        }

        // Login exitoso, revisar si completó onboarding
        final userProfile = await authService.getUserProfile(response.user!.id);

        if (userProfile != null &&
            userProfile['has_completed_onboarding'] == true) {
          context.go('/dashboard');
        } else {
          context.go('/onboarding');
        }
      } else {
        throw Exception('Credenciales incorrectas');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
