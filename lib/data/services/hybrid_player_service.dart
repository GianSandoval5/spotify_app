import 'dart:developer';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_app/core/enums/player_enums.dart';
import 'package:spotify_app/data/services/audio_service.dart';
import 'package:spotify_app/data/services/notification_service.dart';
import 'package:spotify_app/data/services/spotify_service.dart';
import 'package:spotify_app/domain/entities/song_models.dart';

class HybridPlayerService {
  static HybridPlayerService? _instance;
  static HybridPlayerService get instance =>
      _instance ??= HybridPlayerService._();
  HybridPlayerService._();

  final AudioPlayerService _audioService = AudioPlayerService();
  final SpotifyService _spotifyService = SpotifyService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  PlayerMode _currentMode = PlayerMode.local;
  List<Song> _currentPlaylist = [];
  int _currentIndex = 0;

  // Getters
  PlayerMode get currentMode => _currentMode;
  AudioPlayerService get audioService => _audioService;
  SpotifyService get spotifyService => _spotifyService;
  List<Song> get playlist => _currentPlaylist;
  int get currentIndex => _currentIndex;
  Song? get currentSong =>
      _currentPlaylist.isNotEmpty ? _currentPlaylist[_currentIndex] : null;

  // Streams del player actual
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<PlayerState> get playerStateStream => _audioService.playerStateStream;
  Stream<bool> get playingStream => _audioService.playingStream;

  Future<void> init() async {
    await _audioService.init();
    log('HybridPlayerService initialized');
  }

  /// Detecta automáticamente qué player usar basado en la canción
  PlaybackSource _detectPlaybackSource(Song song) {
    if (song.spotifyUri != null && song.spotifyUri!.isNotEmpty) {
      return PlaybackSource.spotify;
    }
    if (song.audioUrl.startsWith('http')) {
      return PlaybackSource.web;
    }
    return PlaybackSource.local;
  }

  /// Verifica si Spotify está disponible para la canción
  Future<bool> _canUseSpotify(Song song) async {
    if (song.spotifyUri == null || song.spotifyUri!.isEmpty) {
      log('Canción sin URI de Spotify, usando reproductor local');
      return false;
    }

    if (!_spotifyService.isConnected) {
      log('Intentando conectar a Spotify SDK...');
      final connected = await _spotifyService.connectToSpotifyRemote();
      if (!connected) {
        log(
          'No se pudo conectar al SDK de Spotify - usuario debe estar logueado en la app nativa',
        );
        return false;
      }
    }

    return true;
  }

  /// Reproduce una sola canción
  Future<bool> playSong(Song song) async {
    try {
      log('Reproduciendo: ${song.title} por ${song.artist}');
      final source = _detectPlaybackSource(song);
      log('Fuente detectada: $source');

      if (source == PlaybackSource.spotify) {
        final canUseSpotify = await _canUseSpotify(song);
        if (canUseSpotify) {
          log('Usando Spotify SDK para reproducir: ${song.spotifyUri}');
          _currentMode = PlayerMode.spotify;
          _currentPlaylist = [song];
          _currentIndex = 0;

          final success = await _spotifyService.play(song.spotifyUri!);
          if (success) {
            log('Reproducción exitosa via Spotify SDK');
            _notificationService.showSpotifySuccess();
            return true;
          } else {
            log(
              'Falló reproducción via Spotify SDK, intentando con reproductor local',
            );
            _notificationService.showSpotifyConnectionError();
          }
        } else {
          // Primera vez que falla Spotify, mostrar ayuda
          if (_currentMode != PlayerMode.local) {
            _notificationService.showSpotifyLoginRequired();
          }
        }
      }

      // Fallback a JustAudio
      log('Usando reproductor local para: ${song.audioUrl}');
      _currentMode = PlayerMode.local;
      _currentPlaylist = [song];
      _currentIndex = 0;

      if (song.audioUrl.isEmpty) {
        log('Error: No hay URL de audio disponible para reproducción local');
        _notificationService.showNoPreviewAvailable(song.title);
        return false;
      }

      await _audioService.setPlaylist([song]);
      await _audioService.play();
      log('Reproducción local iniciada exitosamente');
      _notificationService.showLocalPlayback();
      return true;
    } catch (e) {
      log('Error playing song: $e');
      return false;
    }
  }

  /// Reproduce una playlist
  Future<bool> playPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    try {
      _currentPlaylist = songs;
      _currentIndex = initialIndex;

      if (initialIndex < songs.length) {
        return await playSong(songs[initialIndex]);
      }
      return false;
    } catch (e) {
      log('Error playing playlist: $e');
      return false;
    }
  }

  /// Pausa la reproducción
  Future<bool> pause() async {
    try {
      switch (_currentMode) {
        case PlayerMode.spotify:
          return await _spotifyService.pause();
        case PlayerMode.local:
          await _audioService.pause();
          return true;
      }
    } catch (e) {
      log('Error pausing: $e');
      return false;
    }
  }

  /// Reanuda la reproducción
  Future<bool> resume() async {
    try {
      switch (_currentMode) {
        case PlayerMode.spotify:
          return await _spotifyService.resume();
        case PlayerMode.local:
          await _audioService.play();
          return true;
      }
    } catch (e) {
      log('Error resuming: $e');
      return false;
    }
  }

  /// Siguiente canción
  Future<bool> skipToNext() async {
    if (_currentIndex >= _currentPlaylist.length - 1) return false;

    try {
      _currentIndex++;
      return await playSong(_currentPlaylist[_currentIndex]);
    } catch (e) {
      log('Error skipping to next: $e');
      return false;
    }
  }

  /// Canción anterior
  Future<bool> skipToPrevious() async {
    if (_currentIndex <= 0) return false;

    try {
      _currentIndex--;
      return await playSong(_currentPlaylist[_currentIndex]);
    } catch (e) {
      log('Error skipping to previous: $e');
      return false;
    }
  }

  /// Busca a una posición (solo JustAudio)
  Future<void> seek(Duration position) async {
    if (_currentMode == PlayerMode.local) {
      await _audioService.seek(position);
    }
    // Spotify SDK no soporta seek en la versión actual
  }

  /// Activa/desactiva shuffle
  Future<void> setShuffleMode(bool enabled) async {
    if (_currentMode == PlayerMode.local) {
      await _audioService.setShuffleMode(enabled);
    }
    // Para Spotify se podría implementar shuffle de la playlist localmente
  }

  /// Cambia el modo de bucle
  Future<void> setLoopMode(LoopMode mode) async {
    if (_currentMode == PlayerMode.local) {
      await _audioService.setLoopMode(mode);
    }
    // Para Spotify se podría implementar loop localmente
  }

  /// Conecta a Spotify manualmente
  Future<bool> connectToSpotify() async {
    return await _spotifyService.connectToSpotifyRemote();
  }

  /// Desconecta de Spotify
  Future<void> disconnectFromSpotify() async {
    await _spotifyService.disconnect();
  }

  /// Verifica si Spotify está conectado
  bool get isSpotifyConnected => _spotifyService.isConnected;

  /// Libera recursos
  void dispose() {
    _audioService.dispose();
  }
}
