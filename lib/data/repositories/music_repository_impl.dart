import 'package:dartz/dartz.dart';
import 'package:spotify_app/data/datasources/local_data_source.dart';
import 'package:spotify_app/data/datasources/remote_data_source.dart';
import 'package:spotify_app/data/models/song_model.dart';
import 'package:spotify_app/domain/entities/artist_models.dart';
import 'package:spotify_app/domain/entities/playlist_models.dart';
import 'package:spotify_app/domain/entities/song_models.dart';
import 'package:spotify_app/domain/repositories/music_repository.dart';

class MusicRepositoryImpl implements MusicRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  MusicRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<String, List<Song>>> searchSongs(String query) async {
    try {
      final songModels = await remoteDataSource.searchSongs(query);
      final songs = songModels.map((model) {
        final isFav = localDataSource.isFavorite(model.id);
        return model.toEntity().copyWith(isFavorite: isFav);
      }).toList();
      return Right(songs);
    } catch (e) {
      return Left('Error searching songs: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Artist>>> searchArtists(String query) async {
    try {
      final artists = await remoteDataSource.searchArtists(query);
      return Right(artists);
    } catch (e) {
      return Left('Error searching artists: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Song>>> getSongsByArtist(String artistId) async {
    try {
      final songModels = await remoteDataSource.getSongsByArtist(artistId);
      final songs = songModels.map((model) {
        final isFav = localDataSource.isFavorite(model.id);
        return model.toEntity().copyWith(isFavorite: isFav);
      }).toList();
      return Right(songs);
    } catch (e) {
      return Left('Error getting songs by artist: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Song>>> getRecentlyPlayed() async {
    try {
      final songModels = localDataSource.getRecentlyPlayed();
      final songs = songModels.map((model) => model.toEntity()).toList();
      return Right(songs);
    } catch (e) {
      return Left('Error getting recently played: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Playlist>>> getFeaturedPlaylists() async {
    try {
      final playlists = await remoteDataSource.getFeaturedPlaylists();
      return Right(playlists);
    } catch (e) {
      return Left('Error getting featured playlists: ${e.toString()}');
    }
  }

  @override
  Future<void> addToFavorites(Song song) async {
    final songModel = SongModel.fromEntity(song.copyWith(isFavorite: true));
    await localDataSource.addToFavorites(songModel);
  }

  @override
  Future<void> removeFromFavorites(String songId) async {
    await localDataSource.removeFromFavorites(songId);
  }

  @override
  Future<List<Song>> getFavorites() async {
    final songModels = localDataSource.getFavorites();
    return songModels.map((model) => model.toEntity()).toList();
  }
}
