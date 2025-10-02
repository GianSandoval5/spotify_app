import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/music_repository.dart';
import 'music_event.dart';
import 'music_state.dart';

class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final MusicRepository repository;

  MusicBloc(this.repository) : super(MusicInitial()) {
    on<SearchSongsEvent>(_onSearchSongs);
    on<GetFeaturedPlaylistsEvent>(_onGetFeaturedPlaylists);
    on<GetRecentlyPlayedEvent>(_onGetRecentlyPlayed);
    on<GetSongsByArtistEvent>(_onGetSongsByArtist);
  }

  Future<void> _onSearchSongs(
    SearchSongsEvent event,
    Emitter<MusicState> emit,
  ) async {
    emit(MusicLoading());
    final result = await repository.searchSongs(event.query);
    result.fold(
      (error) => emit(MusicError(error)),
      (songs) => emit(SearchResultsLoaded(songs)),
    );
  }

  Future<void> _onGetFeaturedPlaylists(
    GetFeaturedPlaylistsEvent event,
    Emitter<MusicState> emit,
  ) async {
    emit(MusicLoading());
    final result = await repository.getFeaturedPlaylists();
    result.fold(
      (error) => emit(MusicError(error)),
      (playlists) => emit(FeaturedPlaylistsLoaded(playlists)),
    );
  }

  Future<void> _onGetRecentlyPlayed(
    GetRecentlyPlayedEvent event,
    Emitter<MusicState> emit,
  ) async {
    emit(MusicLoading());
    final result = await repository.getRecentlyPlayed();
    result.fold(
      (error) => emit(MusicError(error)),
      (songs) => emit(RecentlyPlayedLoaded(songs)),
    );
  }

  Future<void> _onGetSongsByArtist(
    GetSongsByArtistEvent event,
    Emitter<MusicState> emit,
  ) async {
    emit(MusicLoading());
    final result = await repository.getSongsByArtist(event.artistId);
    result.fold(
      (error) => emit(MusicError(error)),
      (songs) => emit(ArtistSongsLoaded(songs)),
    );
  }
}