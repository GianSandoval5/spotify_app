import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:spotify_app/core/constants/spotify_config.dart';

class SpotifyAuthService {
  static const MethodChannel _channel = MethodChannel('spotify_auth');
  static const int _requestCode = 1337;

  /// Iniciar el flujo de autenticación usando LoginActivity
  static Future<Map<String, dynamic>?> loginWithActivity() async {
    try {
      log('Iniciando autenticación con LoginActivity...');

      final result = await _channel.invokeMethod('loginWithActivity', {
        'clientId': SpotifyConfig.clientId,
        'redirectUri': SpotifyConfig.redirectUri,
        'scopes': SpotifyConfig.oauthScopes, // Usar scopes OAuth completos
        'requestCode': _requestCode,
      });

      if (result != null) {
        log('Autenticación exitosa: ${result['type']}');
        return Map<String, dynamic>.from(result);
      } else {
        log('Autenticación cancelada o falló');
        return null;
      }
    } catch (e) {
      log('Error en autenticación con LoginActivity: $e');
      return null;
    }
  }

  /// Iniciar el flujo de autenticación usando navegador web
  static Future<Map<String, dynamic>?> loginWithBrowser() async {
    try {
      log('Iniciando autenticación con navegador...');

      final result = await _channel.invokeMethod('loginWithBrowser', {
        'clientId': SpotifyConfig.clientId,
        'redirectUri': SpotifyConfig.redirectUri,
        'scopes': SpotifyConfig.oauthScopes, // Usar scopes OAuth completos
      });

      if (result != null) {
        log('Autenticación con navegador exitosa: ${result['type']}');
        return Map<String, dynamic>.from(result);
      } else {
        log('Autenticación con navegador cancelada o falló');
        return null;
      }
    } catch (e) {
      log('Error en autenticación con navegador: $e');
      return null;
    }
  }

  /// Intercambiar código de autorización por token de acceso
  static Future<Map<String, dynamic>?> exchangeCodeForToken(String code) async {
    try {
      log('Intercambiando código por token...');

      final result = await _channel.invokeMethod('exchangeCodeForToken', {
        'code': code,
        'clientId': SpotifyConfig.clientId,
        'clientSecret': SpotifyConfig.clientSecret,
        'redirectUri': SpotifyConfig.redirectUri,
      });

      if (result != null) {
        log('Token obtenido exitosamente');
        return Map<String, dynamic>.from(result);
      } else {
        log('Error obteniendo token');
        return null;
      }
    } catch (e) {
      log('Error intercambiando código por token: $e');
      return null;
    }
  }

  /// Limpiar cookies y cerrar sesión
  static Future<bool> logout() async {
    try {
      log('Cerrando sesión y limpiando cookies...');

      final result = await _channel.invokeMethod('logout');
      log('Sesión cerrada: $result');

      return result == true;
    } catch (e) {
      log('Error cerrando sesión: $e');
      return false;
    }
  }

  /// Cerrar sesión usando diálogo de Spotify (permite cambiar usuario)
  static Future<Map<String, dynamic>?> logoutWithDialog() async {
    try {
      log('Iniciando logout con diálogo de Spotify...');

      final result = await _channel.invokeMethod('logoutWithDialog', {
        'clientId': SpotifyConfig.clientId,
        'redirectUri': SpotifyConfig.redirectUri,
        'scopes': SpotifyConfig.oauthScopes, // Usar scopes OAuth completos
      });

      if (result != null) {
        log('Logout con diálogo completado: ${result['type']}');
        return Map<String, dynamic>.from(result);
      } else {
        log('Logout con diálogo cancelado');
        return null;
      }
    } catch (e) {
      log('Error en logout con diálogo: $e');
      return null;
    }
  }

  /// Verificar si hay una sesión activa
  static Future<bool> hasActiveSession() async {
    try {
      final result = await _channel.invokeMethod('hasActiveSession');
      return result == true;
    } catch (e) {
      log('Error verificando sesión activa: $e');
      return false;
    }
  }
}
