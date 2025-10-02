import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String imageUrl;
  final String audioUrl;
  final Duration duration;
  final bool isFavorite;
  final String? spotifyUri;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.imageUrl,
    required this.audioUrl,
    required this.duration,
    this.isFavorite = false,
    this.spotifyUri,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? imageUrl,
    String? audioUrl,
    Duration? duration,
    bool? isFavorite,
    String? spotifyUri,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      spotifyUri: spotifyUri ?? this.spotifyUri,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    album,
    imageUrl,
    audioUrl,
    duration,
    isFavorite,
    spotifyUri,
  ];
}
