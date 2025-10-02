import 'package:equatable/equatable.dart';
import 'package:spotify_app/domain/entities/song_models.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Song> songs;

  const Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.songs,
  });

  @override
  List<Object?> get props => [id, name, description, imageUrl, songs];
}