import 'package:dartz/dartz.dart';
import 'package:spotify_app/domain/entities/artist_models.dart';
import 'package:spotify_app/domain/entities/playlist_models.dart';
import 'package:spotify_app/domain/entities/song_models.dart';

abstract class MusicRepository {
  Future<Either<String, List<Song>>> searchSongs(String query);
  Future<Either<String, List<Artist>>> searchArtists(String query);
  Future<Either<String, List<Song>>> getSongsByArtist(String artistId);
  Future<Either<String, List<Song>>> getRecentlyPlayed();
  Future<Either<String, List<Playlist>>> getFeaturedPlaylists();
  Future<void> addToFavorites(Song song);
  Future<void> removeFromFavorites(String songId);
  Future<List<Song>> getFavorites();
}