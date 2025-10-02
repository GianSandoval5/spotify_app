import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
import 'package:spotify_app/core/constants/spotify_config.dart';

class SpotifyDiagnosticService {
  /// Verificar configuración actual
  static void printCurrentConfig() {
    log('=== CONFIGURACIÓN ACTUAL ===');
    log('Client ID: ${SpotifyConfig.clientId}');
    log('Redirect URI: ${SpotifyConfig.redirectUri}');
    log('OAuth Scopes: ${SpotifyConfig.oauthScopes.join(', ')}');
    log('SDK Scopes: ${SpotifyConfig.scopes.join(', ')}');
    log('==============================');
  }

  /// Generar URL de prueba con diferentes configuraciones
  static List<String> generateTestUrls() {
    final baseUrl = 'https://accounts.spotify.com/authorize';

    // URL con scopes OAuth (recomendado)
    final oauthUrl =
        '$baseUrl?'
        'client_id=${Uri.encodeComponent(SpotifyConfig.clientId)}&'
        'response_type=code&'
        'redirect_uri=${Uri.encodeComponent(SpotifyConfig.redirectUri)}&'
        'scope=${Uri.encodeComponent(SpotifyConfig.oauthScopes.join(' '))}&'
        'show_dialog=true';

    // URL con scopes SDK (para comparar)
    final sdkUrl =
        '$baseUrl?'
        'client_id=${Uri.encodeComponent(SpotifyConfig.clientId)}&'
        'response_type=code&'
        'redirect_uri=${Uri.encodeComponent(SpotifyConfig.redirectUri)}&'
        'scope=${Uri.encodeComponent(SpotifyConfig.scopes.join(' '))}&'
        'show_dialog=true';

    // URL sin scopes (mínimo)
    final minimalUrl =
        '$baseUrl?'
        'client_id=${Uri.encodeComponent(SpotifyConfig.clientId)}&'
        'response_type=code&'
        'redirect_uri=${Uri.encodeComponent(SpotifyConfig.redirectUri)}&'
        'show_dialog=true';

    return [oauthUrl, sdkUrl, minimalUrl];
  }

  /// Probar OAuth con diferentes configuraciones
  static Future<void> testOAuthConfigurations() async {
    final urls = generateTestUrls();

    log('=== PROBANDO CONFIGURACIONES ===');

    // Probar OAuth scopes
    log('1. Probando con OAuth scopes...');
    log('URL: ${urls[0]}');

    try {
      final uri1 = Uri.parse(urls[0]);
      if (await canLaunchUrl(uri1)) {
        log('✅ OAuth URL es válida');
      } else {
        log('❌ OAuth URL no se puede abrir');
      }
    } catch (e) {
      log('❌ Error OAuth: $e');
    }

    // Esperar un poco
    await Future.delayed(const Duration(seconds: 1));

    // Probar SDK scopes
    log('2. Probando con SDK scopes...');
    log('URL: ${urls[1]}');

    try {
      final uri2 = Uri.parse(urls[1]);
      if (await canLaunchUrl(uri2)) {
        log('✅ SDK URL es válida');
      } else {
        log('❌ SDK URL no se puede abrir');
      }
    } catch (e) {
      log('❌ Error SDK: $e');
    }

    log('================================');
  }

  /// Generar instrucciones específicas para el panel de Spotify
  static String getSpotifyDashboardInstructions() {
    return '''
🔧 CONFIGURACIÓN SPOTIFY DASHBOARD

📋 Información de tu app:
   Client ID: ${SpotifyConfig.clientId}
   
🎯 Redirect URIs (agregar EXACTAMENTE):
   ${SpotifyConfig.redirectUri}
   
📦 Package Android (agregar):
   com.example.spotify_app
   
🔑 APIs necesarias (habilitar):
   ✅ Web API
   ✅ Android
   
⚠️  IMPORTANTE:
   - El redirect URI debe ser EXACTAMENTE: ${SpotifyConfig.redirectUri}
   - No usar espacios ni caracteres extra
   - Guardar cambios después de cada modificación
   - Esperar 1-2 minutos para que se propague
   
🌐 URL del dashboard:
   https://developer.spotify.com/dashboard/applications/${SpotifyConfig.clientId}
''';
  }

  /// Abrir directamente la configuración de la app en Spotify
  static Future<bool> openSpotifyAppSettings() async {
    final url =
        'https://developer.spotify.com/dashboard/applications/${SpotifyConfig.clientId}';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        log('Abriendo configuración de Spotify...');
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      log('Error abriendo configuración: $e');
      return false;
    }
  }

  /// Diagnosticar problemas comunes
  static List<String> diagnosePotentialIssues() {
    final issues = <String>[];

    // Verificar redirect URI
    if (!SpotifyConfig.redirectUri.contains('com.example.spotify_app')) {
      issues.add('❌ Redirect URI no contiene el package correcto');
    }

    // Verificar formato de redirect URI
    if (!SpotifyConfig.redirectUri.endsWith('://auth')) {
      issues.add('❌ Redirect URI no termina con ://auth');
    }

    // Verificar scopes OAuth
    if (!SpotifyConfig.oauthScopes.contains('user-read-private')) {
      issues.add('⚠️  Falta scope user-read-private para OAuth');
    }

    if (!SpotifyConfig.oauthScopes.contains('user-read-email')) {
      issues.add('⚠️  Falta scope user-read-email para OAuth');
    }

    if (issues.isEmpty) {
      issues.add('✅ Configuración parece correcta');
    }

    return issues;
  }
}
