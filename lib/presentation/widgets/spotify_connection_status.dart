import 'package:flutter/material.dart';
import 'package:spotify_app/data/services/auth_service.dart';
import 'package:spotify_app/injection_container.dart';

class SpotifyConnectionStatus extends StatefulWidget {
  const SpotifyConnectionStatus({super.key});

  @override
  State<SpotifyConnectionStatus> createState() =>
      _SpotifyConnectionStatusState();
}

class _SpotifyConnectionStatusState extends State<SpotifyConnectionStatus> {
  final _authService = sl<AuthService>();
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1DB954).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF1DB954),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Estado de Conexión con Spotify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'La aplicación funciona en modo offline con datos de demostración. '
            'Para usar Spotify real:',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            '1.',
            'Instala la app de Spotify desde Google Play Store',
            Icons.download,
          ),
          const SizedBox(height: 8),
          _buildInstructionItem(
            '2.',
            'Inicia sesión en Spotify con tu cuenta',
            Icons.login,
          ),
          const SizedBox(height: 8),
          _buildInstructionItem(
            '3.',
            'Mantén Spotify ejecutándose en segundo plano',
            Icons.music_note,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isConnecting ? null : _tryConnect,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1DB954)),
                    foregroundColor: const Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: _isConnecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1DB954),
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isConnecting ? 'Conectando...' : 'Intentar Conectar',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _showDetailedInfo(context),
                child: const Text(
                  'Más Info',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF1DB954),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Future<void> _tryConnect() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      final connected = await _authService.tryConnectSpotify();

      if (mounted) {
        if (connected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Conectado a Spotify exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudo conectar. Continuando con datos de demo.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  void _showDetailedInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Información de Conexión',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Esta aplicación puede funcionar de tres formas:\n\n'
            '• Modo Demo: Usando datos de ejemplo (actual)\n'
            '• Spotify SDK: Conectándose directamente a la app de Spotify\n'
            '• Spotify Web: Usando la API web de Spotify\n\n'
            'Para mejor experiencia, instala Spotify y mantén tu sesión activa.\n\n'
            'Si continúas viendo este mensaje después de tener Spotify instalado, '
            'reinicia ambas aplicaciones.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );
  }
}
