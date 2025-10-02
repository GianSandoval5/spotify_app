import 'package:equatable/equatable.dart';
import 'package:spotify_app/domain/entities/playlist_models.dart';
import 'package:spotify_app/domain/entities/song_models.dart';

abstract class MusicState extends Equatable {
  const MusicState();

  @override
  List<Object?> get props => [];
}

class MusicInitial extends MusicState {}

class MusicLoading extends MusicState {}

class SearchResultsLoaded extends MusicState {
  final List<Song> songs;
  const SearchResultsLoaded(this.songs);

  @override
  List<Object?> get props => [songs];
}

class FeaturedPlaylistsLoaded extends MusicState {
  final List<Playlist> playlists;
  const FeaturedPlaylistsLoaded(this.playlists);

  @override
  List<Object?> get props => [playlists];
}

class RecentlyPlayedLoaded extends MusicState {
  final List<Song> songs;
  const RecentlyPlayedLoaded(this.songs);

  @override
  List<Object?> get props => [songs];
}

class ArtistSongsLoaded extends MusicState {
  final List<Song> songs;
  const ArtistSongsLoaded(this.songs);

  @override
  List<Object?> get props => [songs];
}

class MusicError extends MusicState {
  final String message;
  const MusicError(this.message);

  @override
  List<Object?> get props => [message];
}
