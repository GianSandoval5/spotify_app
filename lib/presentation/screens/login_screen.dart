// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:spotify_app/data/services/auth_service.dart';
import 'package:spotify_app/injection_container.dart';
import 'package:spotify_app/presentation/widgets/spotify_config_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(
    text: 'giansando2022@gmail.com',
  );
  final _authService = sl<AuthService>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (_emailController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.loginWithEmail(_emailController.text);

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido, ${user.name}!'),
            backgroundColor: Colors.green,
          ),
        );

        // Intentar conectar con Spotify
        await _authService.tryConnectSpotify();

        Navigator.of(context).pushReplacementNamed('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario no encontrado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithSpotify() async {
    setState(() => _isLoading = true);

    try {
      // Usar SDK oficial basado en ejemplo
      final user = await _authService.loginWithOfficialSpotifySDK();

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Conectado con Spotify! Hola, ${user.name}'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Mensaje cuando falla la conexión
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudo conectar. Verifica que Spotify esté instalado y configurado.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e. Ve SPOTIFY_SETUP_GUIDE.md para ayuda'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 48),

              const Text(
                'Spotify Clone',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Inicia sesión para continuar',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 48),

              // Campo de email
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email (Usuario Demo)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'giansando2022@gmail.com',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1DB954)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de login con email
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              const Text('o', style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 16),

              // Botón de Spotify
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _loginWithSpotify,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1DB954)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note, color: const Color(0xFF1DB954)),
                      const SizedBox(width: 8),
                      const Text(
                        'SDK Oficial Spotify',
                        style: TextStyle(
                          color: Color(0xFF1DB954),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Usuario disponible:\n• Gian Sandoval (giansando2022@gmail.com)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),

              const SizedBox(height: 16),

              // Botón de ayuda OAuth
              TextButton.icon(
                onPressed: () => SpotifyConfigDialog.show(context),
                icon: const Icon(
                  Icons.help_outline,
                  color: Colors.orange,
                  size: 16,
                ),
                label: const Text(
                  'Ayuda con OAuth / INVALID_CLIENT',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
