import 'package:flutter/material.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();
  NotificationService._();

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  void showSpotifyConnectionError() {
    if (_context == null) return;

    _showSnackBar(
      '⚠️ Spotify SDK no disponible',
      'Para usar Spotify SDK, debes estar logueado en la app nativa de Spotify. Reproduciendo localmente...',
      Colors.orange,
      duration: const Duration(seconds: 4),
    );
  }

  void showSpotifySuccess() {
    if (_context == null) return;

    _showSnackBar(
      '🎵 Spotify conectado',
      'Reproduciendo via Spotify SDK',
      Colors.green,
      duration: const Duration(seconds: 2),
    );
  }

  void showLocalPlayback() {
    if (_context == null) return;

    _showSnackBar(
      '🔊 Reproductor local',
      'Reproduciendo preview de 30 segundos',
      Colors.blue,
      duration: const Duration(seconds: 2),
    );
  }

  void showNoAudioUrlError() {
    if (_context == null) return;

    _showSnackBar(
      '❌ No disponible',
      'Esta canción no tiene preview disponible',
      Colors.red,
      duration: const Duration(seconds: 3),
    );
  }

  void showNoPreviewAvailable(String songTitle) {
    if (_context == null) return;

    _showDialog(
      '🎵 Sin preview disponible',
      '"$songTitle" no tiene preview de 30 segundos disponible.\n\n'
          '✅ SOLUCIÓN FÁCIL:\n'
          'Busca canciones con etiqueta "Preview" (azul) - estas se reproducen inmediatamente.\n\n'
          '🔧 ALTERNATIVA AVANZADA:\n'
          'Para canciones "SDK only" (naranja):\n'
          '1. Abre la app de Spotify en tu teléfono\n'
          '2. Inicia sesión si no lo has hecho\n'
          '3. Mantén Spotify abierto\n'
          '4. Regresa aquí e intenta de nuevo\n\n'
          '💡 Tip: Las canciones demo (marcadas como Demo) siempre funcionan.',
    );
  }

  void showSpotifyLoginRequired() {
    if (_context == null) return;

    _showDialog(
      '🎵 Spotify SDK',
      'Para reproducir música completa via Spotify SDK:\n\n'
          '1. Asegúrate de tener Spotify instalado\n'
          '2. Abre Spotify y loguéate\n'
          '3. Mantén Spotify abierto\n'
          '4. Intenta reproducir de nuevo\n\n'
          'Mientras tanto, puedes escuchar previews de 30 segundos.',
    );
  }

  void _showSnackBar(
    String title,
    String message,
    Color color, {
    Duration? duration,
  }) {
    if (_context == null) return;

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(message, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: color,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showDialog(String title, String message) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
