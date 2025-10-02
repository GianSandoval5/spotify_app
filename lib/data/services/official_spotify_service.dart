import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_app/core/constants/spotify_config.dart';

class OfficialSpotifyService {
  static bool _connected = false;
  static String? _currentAccessToken;

  /// Verificar si está conectado al SDK
  static bool get isConnected => _connected;

  /// Obtener el access token actual
  static String? get accessToken => _currentAccessToken;

  /// Conectar al Spotify Remote SDK (siguiendo ejemplo oficial)
  static Future<bool> connectToSpotifyRemote() async {
    try {
      log('Conectando al Spotify Remote SDK...');

      final result = await SpotifySdk.connectToSpotifyRemote(
        clientId: SpotifyConfig.clientId,
        redirectUrl: SpotifyConfig.redirectUri,
      );

      _connected = result;

      if (result) {
        log('✅ Conexión exitosa al Spotify Remote SDK');
      } else {
        log('❌ Falló la conexión al Spotify Remote SDK');
      }

      return result;
    } on PlatformException catch (e) {
      log('Error PlatformException: ${e.code} - ${e.message}');
      _connected = false;
      return false;
    } on MissingPluginException {
      log('Error: Plugin no implementado');
      _connected = false;
      return false;
    } catch (e) {
      log('Error inesperado: $e');
      _connected = false;
      return false;
    }
  }

  /// Obtener Access Token (siguiendo ejemplo oficial)
  static Future<String?> getAccessToken() async {
    try {
      log('Obteniendo Access Token...');

      // Usar scopes del ejemplo oficial
      const scope =
          'app-remote-control, '
          'user-modify-playback-state, '
          'playlist-read-private, '
          'playlist-modify-public, '
          'user-read-currently-playing, '
          'user-read-private, '
          'user-read-email, '
          'streaming';

      final authenticationToken = await SpotifySdk.getAccessToken(
        clientId: SpotifyConfig.clientId,
        redirectUrl: SpotifyConfig.redirectUri,
        scope: scope,
      );

      _currentAccessToken = authenticationToken;
      log(
        '✅ Access Token obtenido: ${authenticationToken.substring(0, 20)}...',
      );

      return authenticationToken;
    } on PlatformException catch (e) {
      log('Error obteniendo token: ${e.code} - ${e.message}');
      return null;
    } on MissingPluginException {
      log('Error: Plugin no implementado para getAccessToken');
      return null;
    } catch (e) {
      log('Error inesperado obteniendo token: $e');
      return null;
    }
  }

  /// Desconectar del SDK
  static Future<bool> disconnect() async {
    try {
      log('Desconectando del Spotify SDK...');

      final result = await SpotifySdk.disconnect();

      if (result) {
        _connected = false;
        _currentAccessToken = null;
        log('✅ Desconexión exitosa');
      } else {
        log('❌ Falló la desconexión');
      }

      return result;
    } on PlatformException catch (e) {
      log('Error desconectando: ${e.code} - ${e.message}');
      return false;
    } on MissingPluginException {
      log('Error: Plugin no implementado para disconnect');
      return false;
    } catch (e) {
      log('Error inesperado desconectando: $e');
      return false;
    }
  }

  /// Flujo completo: conectar + obtener token
  static Future<Map<String, dynamic>> authenticateComplete() async {
    try {
      log('🎵 Iniciando autenticación completa con Spotify...');

      // Paso 1: Conectar al SDK
      final connected = await connectToSpotifyRemote();
      if (!connected) {
        return {
          'success': false,
          'error': 'No se pudo conectar al Spotify Remote SDK',
          'connected': false,
          'token': null,
        };
      }

      // Paso 2: Obtener access token
      final token = await getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'No se pudo obtener el access token',
          'connected': true,
          'token': null,
        };
      }

      log('🎉 Autenticación completa exitosa!');
      return {
        'success': true,
        'error': null,
        'connected': true,
        'token': token,
      };
    } catch (e) {
      log('Error en autenticación completa: $e');
      return {
        'success': false,
        'error': 'Error inesperado: $e',
        'connected': false,
        'token': null,
      };
    }
  }

  /// Verificar estado de la conexión usando stream
  static Stream<bool> get connectionStatusStream {
    return SpotifySdk.subscribeConnectionStatus().map((status) {
      _connected = status.connected;
      return status.connected;
    });
  }

  /// Obtener estado del player (requiere conexión)
  static Future<dynamic> getPlayerState() async {
    if (!_connected) {
      log('❌ No conectado - no se puede obtener player state');
      return null;
    }

    try {
      return await SpotifySdk.getPlayerState();
    } catch (e) {
      log('Error obteniendo player state: $e');
      return null;
    }
  }

  /// Reproducir una canción (requiere conexión)
  static Future<bool> play([String? spotifyUri]) async {
    if (!_connected) {
      log('❌ No conectado - no se puede reproducir');
      return false;
    }

    try {
      if (spotifyUri != null) {
        await SpotifySdk.play(spotifyUri: spotifyUri);
      } else {
        await SpotifySdk.resume();
      }
      log('✅ Reproducción iniciada');
      return true;
    } catch (e) {
      log('Error reproduciendo: $e');
      return false;
    }
  }

  /// Pausar reproducción
  static Future<bool> pause() async {
    if (!_connected) {
      log('❌ No conectado - no se puede pausar');
      return false;
    }

    try {
      await SpotifySdk.pause();
      log('✅ Reproducción pausada');
      return true;
    } catch (e) {
      log('Error pausando: $e');
      return false;
    }
  }

  /// Siguiente canción
  static Future<bool> skipNext() async {
    if (!_connected) {
      log('❌ No conectado - no se puede saltar canción');
      return false;
    }

    try {
      await SpotifySdk.skipNext();
      log('✅ Saltó a siguiente canción');
      return true;
    } catch (e) {
      log('Error saltando canción: $e');
      return false;
    }
  }

  /// Canción anterior
  static Future<bool> skipPrevious() async {
    if (!_connected) {
      log('❌ No conectado - no se puede ir a canción anterior');
      return false;
    }

    try {
      await SpotifySdk.skipPrevious();
      log('✅ Saltó a canción anterior');
      return true;
    } catch (e) {
      log('Error yendo a canción anterior: $e');
      return false;
    }
  }
}
