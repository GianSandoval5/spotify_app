import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
import 'package:spotify_app/core/constants/spotify_config.dart';

class SimplifiedSpotifyAuthService {
  /// Generar URL de autorización OAuth 2.0 y abrirla en el navegador
  static Future<bool> loginWithOAuth() async {
    try {
      log('Generando URL de OAuth...');

      final authUrl = _buildAuthUrl();
      log('URL generada: $authUrl');

      final uri = Uri.parse(authUrl);

      if (await canLaunchUrl(uri)) {
        log('Abriendo navegador para OAuth...');
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          log('OAuth iniciado exitosamente');
          return true;
        } else {
          log('Error: No se pudo abrir el navegador');
          return false;
        }
      } else {
        log('Error: No se puede abrir la URL');
        return false;
      }
    } catch (e) {
      log('Error en OAuth: $e');
      return false;
    }
  }

  /// Construir URL de autorización OAuth 2.0
  static String _buildAuthUrl() {
    final params = {
      'client_id': SpotifyConfig.clientId,
      'response_type': 'code',
      'redirect_uri': SpotifyConfig.redirectUri,
      'scope': SpotifyConfig.oauthScopes.join(' '),
      'show_dialog': 'true', // Permite cambio de usuario
    };

    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    return 'https://accounts.spotify.com/authorize?$query';
  }

  /// URL para logout manual (abre configuración de Spotify)
  static Future<bool> openSpotifyLogout() async {
    try {
      const logoutUrl = 'https://accounts.spotify.com/logout';
      final uri = Uri.parse(logoutUrl);

      if (await canLaunchUrl(uri)) {
        log('Abriendo página de logout de Spotify...');
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      log('Error abriendo logout: $e');
      return false;
    }
  }

  /// Generar URL con información de configuración
  static String getConfigInstructions() {
    return '''
🔧 CONFIGURACIÓN REQUERIDA:

1. Ve a: https://developer.spotify.com/dashboard
2. Crea/edita tu aplicación
3. En "Redirect URIs" agrega EXACTAMENTE:
   ${SpotifyConfig.redirectUri}

4. Guarda los cambios

❌ Error "INVALID_CLIENT" = Redirect URI no configurado
✅ OAuth funciona = Redirect URI correcto

Redirect URI actual: ${SpotifyConfig.redirectUri}
''';
  }
}
