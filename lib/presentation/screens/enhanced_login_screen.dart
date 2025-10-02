// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:spotify_app/data/services/auth_service.dart';
import 'package:spotify_app/injection_container.dart';
import 'package:spotify_app/presentation/widgets/spotify_config_dialog.dart';

class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  final _emailController = TextEditingController(
    text: 'giansando2022@gmail.com',
  );
  final _authService = sl<AuthService>();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _setStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
  }

  Future<void> _loginWithEmail() async {
    if (_emailController.text.isEmpty) return;

    setState(() => _isLoading = true);
    _setStatus('Iniciando sesión con email...');

    try {
      final user = await _authService.loginWithEmail(_emailController.text);

      if (user != null && mounted) {
        _setStatus('¡Bienvenido, ${user.name}!');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido, ${user.name}!'),
            backgroundColor: Colors.green,
          ),
        );

        // Intentar conectar con Spotify
        _setStatus('Intentando conectar con Spotify...');
        await _authService.tryConnectSpotify();

        Navigator.of(context).pushReplacementNamed('/home');
      } else if (mounted) {
        _setStatus('Usuario no encontrado');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario no encontrado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _setStatus('Error: $e');
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

  Future<void> _loginWithSpotifyOAuth() async {
    setState(() => _isLoading = true);
    _setStatus('Iniciando autenticación OAuth con Spotify...');

    try {
      final user = await _authService.loginWithSpotifyOAuth();

      if (user != null && mounted) {
        _setStatus('¡Autenticación OAuth exitosa!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido, ${user.name}!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacementNamed('/home');
      } else if (mounted) {
        _setStatus('Autenticación OAuth cancelada o falló');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo autenticar con Spotify OAuth'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _setStatus('Error en OAuth: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error OAuth: $e'),
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

  Future<void> _loginWithSpotifySDK() async {
    setState(() => _isLoading = true);
    _setStatus('Conectando con SDK Oficial de Spotify...');

    try {
      // Usar SDK oficial basado en ejemplo
      final user = await _authService.loginWithOfficialSpotifySDK();

      if (user != null && mounted) {
        _setStatus('¡Conectado con SDK Oficial!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Conectado con Spotify! Hola, ${user.name}'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacementNamed('/home');
      } else if (mounted) {
        _setStatus('SDK falló - verifica configuración');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo conectar con Spotify SDK. Verifica que Spotify esté instalado y configurado.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _setStatus('Error SDK: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error SDK: $e. Ve SPOTIFY_SETUP_GUIDE.md para ayuda',
            ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

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

              const SizedBox(height: 32),

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
                'Elige tu método de autenticación',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 32),

              // Estado
              if (_statusMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF282828),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(
                      color: Color(0xFF1DB954),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

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

              const SizedBox(height: 16),

              // Botón de login con email
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loginWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.email, color: Colors.white),
                  label: const Text(
                    'Login con Email (Demo)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'o conectar con Spotify',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 24),

              // Botón OAuth (recomendado)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loginWithSpotifyOAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.security, color: Colors.white),
                  label: const Text(
                    'OAuth con Spotify (Recomendado)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón SDK
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loginWithSpotifySDK,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1DB954)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.music_note, color: Color(0xFF1DB954)),
                  label: const Text(
                    'SDK Oficial Spotify',
                    style: TextStyle(
                      color: Color(0xFF1DB954),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Loading indicator
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFF1DB954)),

              const SizedBox(height: 24),

              // Información
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF282828),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Métodos de Autenticación:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      'Email Demo',
                      'Usuario: Gian Sandoval (giansando2022@gmail.com)',
                      Icons.person,
                    ),
                    _buildInfoItem(
                      'OAuth',
                      'Autenticación completa + logout con cambio de usuario',
                      Icons.security,
                    ),
                    _buildInfoItem(
                      'SDK Oficial',
                      'Conexión con SDK oficial (requiere Spotify instalado)',
                      Icons.link,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF1DB954).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF1DB954),
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'OAuth incluye logout mejorado con opción de cambiar usuario',
                                  style: TextStyle(
                                    color: Color(0xFF1DB954),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_outlined,
                                color: Colors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    SpotifyConfigDialog.show(context);
                                  },
                                  child: const Text(
                                    'Si ves "INVALID_CLIENT", toca aquí para ayuda',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1DB954), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1DB954),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
