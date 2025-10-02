import 'package:hive/hive.dart';
import 'package:spotify_app/domain/entities/song_models.dart';

part 'song_model.g.dart';

@HiveType(typeId: 0)
class SongModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String album;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final String audioUrl;

  @HiveField(6)
  final int durationInSeconds;

  @HiveField(7)
  final bool isFavorite;

  @HiveField(8)
  final String? spotifyUri;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.imageUrl,
    required this.audioUrl,
    required this.durationInSeconds,
    this.isFavorite = false,
    this.spotifyUri,
  });

  factory SongModel.fromEntity(Song song) {
    return SongModel(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      imageUrl: song.imageUrl,
      audioUrl: song.audioUrl,
      durationInSeconds: song.duration.inSeconds,
      isFavorite: song.isFavorite,
      spotifyUri: song.spotifyUri,
    );
  }

  Song toEntity() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      duration: Duration(seconds: durationInSeconds),
      isFavorite: isFavorite,
      spotifyUri: spotifyUri,
    );
  }

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? '',
      title: json['name'] ?? 'Unknown',
      artist: json['artists']?[0]?['name'] ?? 'Unknown Artist',
      album: json['album']?['name'] ?? 'Unknown Album',
      imageUrl: json['album']?['images']?[0]?['url'] ?? '',
      audioUrl: json['preview_url'] ?? '',
      durationInSeconds: (json['duration_ms'] ?? 0) ~/ 1000,
      spotifyUri: json['uri'],
    );
  }
}
