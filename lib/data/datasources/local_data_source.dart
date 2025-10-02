import 'package:hive_flutter/hive_flutter.dart';
import 'package:spotify_app/data/models/song_model.dart';

class LocalDataSource {
  static const String favoritesBox = 'favorites';
  static const String recentlyPlayedBox = 'recently_played';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SongModelAdapter());
    await Hive.openBox<SongModel>(favoritesBox);
    await Hive.openBox<SongModel>(recentlyPlayedBox);
  }

  Future<void> addToFavorites(SongModel song) async {
    final box = Hive.box<SongModel>(favoritesBox);
    await box.put(song.id, song);
  }

  Future<void> removeFromFavorites(String songId) async {
    final box = Hive.box<SongModel>(favoritesBox);
    await box.delete(songId);
  }

  List<SongModel> getFavorites() {
    final box = Hive.box<SongModel>(favoritesBox);
    return box.values.toList();
  }

  bool isFavorite(String songId) {
    final box = Hive.box<SongModel>(favoritesBox);
    return box.containsKey(songId);
  }

  Future<void> addToRecentlyPlayed(SongModel song) async {
    final box = Hive.box<SongModel>(recentlyPlayedBox);
    await box.put(song.id, song);
  }

  List<SongModel> getRecentlyPlayed() {
    final box = Hive.box<SongModel>(recentlyPlayedBox);
    return box.values.toList().reversed.take(20).toList();
  }
}