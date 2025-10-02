import 'dart:developer';

import 'package:spotify_app/core/constants/spotify_config.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyService {
  static SpotifyService? _instance;
  static SpotifyService get instance => _instance ??= SpotifyService._();
  SpotifyService._();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Conecta a la aplicación Spotify
  Future<bool> connectToSpotifyRemote() async {
    try {
      log('Intentando conectar a Spotify SDK...');

      final result = await SpotifySdk.connectToSpotifyRemote(
        clientId: SpotifyConfig.clientId,
        redirectUrl: SpotifyConfig.redirectUri,
      );

      if (result) {
        _isConnected = true;
        log('Conectado a Spotify SDK exitosamente!');
        return true;
      } else {
        log('No se pudo conectar a Spotify SDK - resultado falso');
        _isConnected = false;
        return false;
      }
    } catch (e) {
      log('Error conectando a Spotify SDK: $e');
      _isConnected = false;

      // Manejar errores específicos
      if (e.toString().contains('NotLoggedInException') ||
          e.toString().contains('User has logged out')) {
        log('Usuario no está logueado en la app nativa de Spotify');
      } else if (e.toString().contains('SpotifyNotInstalledException')) {
        log('Spotify no está instalado en el dispositivo');
      }

      return false;
    }
  }

  /// Desconecta de Spotify
  Future<void> disconnect() async {
    try {
      await SpotifySdk.disconnect();
      _isConnected = false;
      log('Desconectado de Spotify');
    } catch (e) {
      log('Error desconectando de Spotify: $e');
    }
  }

  /// Reproduce una canción por URI
  Future<bool> play(String spotifyUri) async {
    if (!_isConnected) {
      log('No conectado a Spotify SDK - intentando reconectar...');
      final reconnected = await connectToSpotifyRemote();
      if (!reconnected) {
        log('No se pudo reconectar a Spotify SDK');
        return false;
      }
    }

    try {
      await SpotifySdk.play(spotifyUri: spotifyUri);
      log('Reproduciendo via Spotify SDK: $spotifyUri');
      return true;
    } catch (e) {
      log('Error reproduciendo canción via Spotify SDK: $e');

      // Si hay error de usuario no logueado, marcar como desconectado
      if (e.toString().contains('NotLoggedInException') ||
          e.toString().contains('User has logged out')) {
        _isConnected = false;
        log(
          'Usuario se ha deslogueado de Spotify - marcando como desconectado',
        );
      }

      return false;
    }
  }

  /// Pausa la reproducción
  Future<bool> pause() async {
    if (!_isConnected) return false;

    try {
      await SpotifySdk.pause();
      log('Pausado');
      return true;
    } catch (e) {
      log('Error pausando: $e');
      return false;
    }
  }

  /// Resume la reproducción
  Future<bool> resume() async {
    if (!_isConnected) return false;

    try {
      await SpotifySdk.resume();
      log('Reanudado');
      return true;
    } catch (e) {
      log('Error reanudando: $e');
      return false;
    }
  }

  /// Siguiente canción
  Future<bool> skipNext() async {
    if (!_isConnected) return false;

    try {
      await SpotifySdk.skipNext();
      log('Siguiente canción');
      return true;
    } catch (e) {
      log('Error saltando a siguiente: $e');
      return false;
    }
  }

  /// Canción anterior
  Future<bool> skipPrevious() async {
    if (!_isConnected) return false;

    try {
      await SpotifySdk.skipPrevious();
      log('Canción anterior');
      return true;
    } catch (e) {
      log('Error saltando a anterior: $e');
      return false;
    }
  }

  /// Obtiene el estado actual del reproductor
  Future<dynamic> getPlayerState() async {
    if (!_isConnected) return null;

    try {
      return await SpotifySdk.getPlayerState();
    } catch (e) {
      log('Error obteniendo estado del reproductor: $e');
      return null;
    }
  }

  /// Stream del estado del reproductor
  Stream<dynamic> get playerStateStream {
    if (!_isConnected) {
      return Stream.empty();
    }
    return SpotifySdk.subscribePlayerState();
  }

  /// Verifica si Spotify está instalado
  Future<bool> isSpotifyAppInstalled() async {
    try {
      // Método alternativo para verificar si Spotify está disponible
      final result = await connectToSpotifyRemote();
      if (result) {
        await disconnect();
      }
      return result;
    } catch (e) {
      log('Error verificando si Spotify está instalado: $e');
      return false;
    }
  }
}
