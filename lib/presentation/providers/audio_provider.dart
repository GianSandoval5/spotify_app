import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_app/core/enums/player_enums.dart';
import 'package:spotify_app/data/services/hybrid_player_service.dart';
import 'package:spotify_app/domain/entities/song_models.dart';

class AudioProvider extends ChangeNotifier {
  final HybridPlayerService _hybridService = HybridPlayerService.instance;

  // Getters actualizados
  HybridPlayerService get audioService => _hybridService;
  Song? get currentSong => _hybridService.currentSong;
  List<Song> get playlist => _hybridService.playlist;
  int get currentIndex => _hybridService.currentIndex;
  PlayerMode get currentMode => _hybridService.currentMode;
  bool get isSpotifyConnected => _hybridService.isSpotifyConnected;

  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;

  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;

  /// Reproduce una canción (híbrido)
  Future<void> playSong(Song song) async {
    final success = await _hybridService.playSong(song);
    if (success) {
      notifyListeners();
    }
  }

  /// Reproduce una playlist (híbrido)
  Future<void> playPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    final success = await _hybridService.playPlaylist(
      songs,
      initialIndex: initialIndex,
    );
    if (success) {
      notifyListeners();
    }
  }

  /// Reanuda la reproducción
  Future<void> play() async {
    final success = await _hybridService.resume();
    if (success) {
      notifyListeners();
    }
  }

  /// Pausa la reproducción
  Future<void> pause() async {
    final success = await _hybridService.pause();
    if (success) {
      notifyListeners();
    }
  }

  /// Busca a una posición (solo para JustAudio)
  Future<void> seek(Duration position) async {
    await _hybridService.seek(position);
  }

  /// Siguiente canción
  Future<void> skipToNext() async {
    final success = await _hybridService.skipToNext();
    if (success) {
      notifyListeners();
    }
  }

  /// Canción anterior
  Future<void> skipToPrevious() async {
    final success = await _hybridService.skipToPrevious();
    if (success) {
      notifyListeners();
    }
  }

  /// Va a un índice específico
  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < playlist.length) {
      final success = await _hybridService.playSong(playlist[index]);
      if (success) {
        notifyListeners();
      }
    }
  }

  /// Activa/desactiva shuffle
  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _hybridService.setShuffleMode(_isShuffleEnabled);
    notifyListeners();
  }

  /// Cambia el modo de bucle
  Future<void> toggleLoopMode() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    await _hybridService.setLoopMode(_loopMode);
    notifyListeners();
  }

  /// Conecta a Spotify
  Future<bool> connectToSpotify() async {
    final success = await _hybridService.connectToSpotify();
    if (success) {
      notifyListeners();
    }
    return success;
  }

  /// Desconecta de Spotify
  Future<void> disconnectFromSpotify() async {
    await _hybridService.disconnectFromSpotify();
    notifyListeners();
  }

  /// Obtiene información del player actual
  String get currentPlayerInfo {
    switch (currentMode) {
      case PlayerMode.spotify:
        return 'Playing via Spotify';
      case PlayerMode.local:
        return 'Playing locally';
    }
  }
}
