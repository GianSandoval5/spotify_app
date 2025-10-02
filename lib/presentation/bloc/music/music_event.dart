import 'package:equatable/equatable.dart';

abstract class MusicEvent extends Equatable {
  const MusicEvent();

  @override
  List<Object?> get props => [];
}

class SearchSongsEvent extends MusicEvent {
  final String query;
  const SearchSongsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class GetFeaturedPlaylistsEvent extends MusicEvent {}

class GetRecentlyPlayedEvent extends MusicEvent {}

class GetSongsByArtistEvent extends MusicEvent {
  final String artistId;
  const GetSongsByArtistEvent(this.artistId);

  @override
  List<Object?> get props => [artistId];
}