// lib/data/services/audio_player_service.dart
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:spotify_app/domain/entities/song_models.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _playlist = [];
  int _currentIndex = 0;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _playlist.isNotEmpty ? _playlist[_currentIndex] : null;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  Future<void> init() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.spotify.clone.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );

    _audioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  Future<void> setPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    _playlist = songs;
    _currentIndex = initialIndex;

    final playlist = ConcatenatingAudioSource(
      children: songs.map((song) {
        return AudioSource.uri(
          Uri.parse(song.audioUrl),
          tag: MediaItem(
            id: song.id,
            album: song.album,
            title: song.title,
            artist: song.artist,
            artUri: Uri.parse(song.imageUrl),
            duration: song.duration,
          ),
        );
      }).toList(),
    );

    await _audioPlayer.setAudioSource(
      playlist,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> skipToNext() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await _audioPlayer.seekToNext();
    }
  }

  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _audioPlayer.seekToPrevious();
    }
  }

  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await _audioPlayer.seek(Duration.zero, index: index);
    }
  }

  Future<void> setShuffleMode(bool enabled) async {
    await _audioPlayer.setShuffleModeEnabled(enabled);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _audioPlayer.setLoopMode(mode);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
 