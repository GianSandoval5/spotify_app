import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_app/data/services/simplified_spotify_auth_service.dart';
import 'package:spotify_app/data/services/spotify_diagnostic_service.dart';

class SpotifyConfigDialog extends StatelessWidget {
  const SpotifyConfigDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF282828),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF1DB954),
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Configuración OAuth Spotify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estado actual
                    _buildStatusCard(),

                    const SizedBox(height: 16),

                    // Instrucciones
                    _buildInstructionsCard(),

                    const SizedBox(height: 16),

                    // Información del redirect URI
                    _buildRedirectURICard(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final opened =
                              await SimplifiedSpotifyAuthService.loginWithOAuth();
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo abrir el navegador'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.launch),
                        label: const Text('Probar OAuth'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await SpotifyDiagnosticService.openSpotifyAppSettings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.settings),
                        label: const Text('Dashboard'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          SpotifyDiagnosticService.printCurrentConfig();
                          SpotifyDiagnosticService.testOAuthConfigurations();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          foregroundColor: Colors.blue,
                        ),
                        icon: const Icon(Icons.bug_report),
                        label: const Text('Diagnóstico'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text('Cerrar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                'Error: INVALID_CLIENT',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Este error indica que el Redirect URI no está configurado correctamente en tu aplicación de Spotify.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1DB954).withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1DB954).withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings, color: Color(0xFF1DB954), size: 20),
              SizedBox(width: 8),
              Text(
                'Pasos para Configurar',
                style: TextStyle(
                  color: Color(0xFF1DB954),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Ve a developer.spotify.com/dashboard'),
          _buildStep('2', 'Inicia sesión con tu cuenta Spotify'),
          _buildStep('3', 'Crea una nueva aplicación o edita una existente'),
          _buildStep('4', 'Ve a "Settings" de tu aplicación'),
          _buildStep('5', 'En "Redirect URIs" haz clic en "Add Redirect URI"'),
          _buildStep('6', 'Pega el URI exacto que aparece abajo'),
          _buildStep('7', 'Haz clic en "Save"'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF1DB954),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedirectURICard() {
    const redirectUri = 'com.example.spotify_app://auth';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Redirect URI Requerido',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Copia y pega EXACTAMENTE este URI en tu aplicación de Spotify:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    redirectUri,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: redirectUri));
                  },
                  icon: const Icon(Icons.copy, color: Colors.orange, size: 18),
                  tooltip: 'Copiar URI',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '⚠️ IMPORTANTE: Debe ser exactamente como aparece arriba, incluyendo mayúsculas y minúsculas.',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SpotifyConfigDialog(),
    );
  }
}
