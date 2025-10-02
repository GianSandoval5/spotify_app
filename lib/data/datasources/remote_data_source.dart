import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotify_app/data/models/song_model.dart';
import 'package:spotify_app/domain/entities/artist_models.dart';
import 'package:spotify_app/domain/entities/playlist_models.dart';
import 'package:spotify_app/core/constants/spotify_config.dart';
import 'package:spotify_app/domain/entities/song_models.dart';
import 'package:spotify_app/data/services/auth_service.dart';

class RemoteDataSource {
  final String baseUrl = 'https://api.spotify.com/v1';
  final AuthService _authService;
  String? _accessToken;

  RemoteDataSource({required AuthService authService})
    : _authService = authService;

  // Obtener token de acceso usando Client Credentials Flow
  Future<String?> _getAccessToken() async {
    if (_accessToken != null) return _accessToken;

    try {
      final credentials = base64Encode(
        utf8.encode('${SpotifyConfig.clientId}:${SpotifyConfig.clientSecret}'),
      );

      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        return _accessToken;
      }
    } catch (e) {
      print('Error obteniendo token: $e');
    }

    return null;
  }

  // Verificar si el usuario está autenticado
  Future<bool> _ensureAuthenticated() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      print('Usuario no autenticado, intentando login automático...');

      // Intentar login con usuario por defecto
      const defaultEmail = 'gsandoval@flupione.com';
      final user = await _authService.loginWithEmail(defaultEmail);

      if (user != null) {
        print('Login automático exitoso: ${user.name}');
        // Intentar conectar con Spotify
        await _authService.tryConnectSpotify();
        return true;
      } else {
        print('No se pudo autenticar automáticamente');
        return false;
      }
    }
    return true;
  }

  // Buscar canciones en Spotify
  Future<List<SongModel>> searchSongs(String query) async {
    // Asegurar autenticación antes de hacer la búsqueda
    final authenticated = await _ensureAuthenticated();
    if (!authenticated) {
      print('Usuario no autenticado, usando datos mock');
      return _getMockSongs()
          .where(
            (song) =>
                song.title.toLowerCase().contains(query.toLowerCase()) ||
                song.artist.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    try {
      final token = await _getAccessToken();
      if (token == null) {
        // Si no hay token, usar datos mock como fallback
        return _getMockSongs()
            .where(
              (song) =>
                  song.title.toLowerCase().contains(query.toLowerCase()) ||
                  song.artist.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/search?q=${Uri.encodeComponent(query)}&type=track&limit=20',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks']['items'] as List;

        final currentUser = await _authService.getCurrentUser();
        print(
          'Búsqueda realizada por: ${currentUser?.name ?? "Usuario anónimo"}',
        );

        // Mapear canciones y separar las que tienen preview
        final songsWithPreview = <SongModel>[];
        final songsWithoutPreview = <SongModel>[];

        for (final track in tracks) {
          final song = SongModel(
            id: track['id'],
            title: track['name'],
            artist: track['artists'][0]['name'],
            album: track['album']['name'],
            imageUrl: track['album']['images'].isNotEmpty
                ? track['album']['images'][0]['url']
                : '',
            audioUrl: track['preview_url'] ?? '',
            durationInSeconds: (track['duration_ms'] / 1000).round(),
            spotifyUri: track['uri'],
          );

          if (track['preview_url'] != null) {
            songsWithPreview.add(song);
          } else {
            songsWithoutPreview.add(song);
          }
        }

        print('Canciones con preview: ${songsWithPreview.length}');
        print('Canciones sin preview: ${songsWithoutPreview.length}');

        // Si hay muy pocas canciones con preview, agregar canciones mock funcionales
        if (songsWithPreview.length < 3) {
          print(
            'Pocas canciones con preview, agregando canciones demo funcionales...',
          );
          final mockSongs = _getMockSongs()
              .where(
                (song) =>
                    song.title.toLowerCase().contains(query.toLowerCase()) ||
                    song.artist.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

          // Agregar las mock al inicio para que aparezcan primero
          return [...mockSongs, ...songsWithPreview, ...songsWithoutPreview];
        }

        // Devolver primero las que tienen preview, luego las que no
        return [...songsWithPreview, ...songsWithoutPreview];
      }
    } catch (e) {
      print('Error buscando canciones: $e');
    }

    // Fallback a datos mock si falla la API
    return _getMockSongs()
        .where(
          (song) =>
              song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.artist.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Buscar artistas en Spotify
  Future<List<Artist>> searchArtists(String query) async {
    final authenticated = await _ensureAuthenticated();
    if (!authenticated) {
      return _getMockArtists()
          .where(
            (artist) => artist.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    try {
      final token = await _getAccessToken();
      if (token == null) {
        return _getMockArtists()
            .where(
              (artist) =>
                  artist.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/search?q=${Uri.encodeComponent(query)}&type=artist&limit=20',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final artists = data['artists']['items'] as List;

        return artists
            .map(
              (artist) => Artist(
                id: artist['id'],
                name: artist['name'],
                imageUrl: artist['images'].isNotEmpty
                    ? artist['images'][0]['url']
                    : '',
                followers: artist['followers']['total'],
                genres: List<String>.from(artist['genres']),
              ),
            )
            .toList();
      }
    } catch (e) {
      print('Error buscando artistas: $e');
    }

    return _getMockArtists()
        .where(
          (artist) => artist.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Obtener canciones de un artista
  Future<List<SongModel>> getSongsByArtist(String artistId) async {
    final authenticated = await _ensureAuthenticated();
    if (!authenticated) {
      return _getMockSongs()
          .where((song) => song.artist.contains(artistId))
          .toList();
    }

    try {
      final token = await _getAccessToken();
      if (token == null) {
        return _getMockSongs()
            .where((song) => song.artist.contains(artistId))
            .toList();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/artists/$artistId/top-tracks?market=US'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks'] as List;

        return tracks
            .map(
              (track) => SongModel(
                id: track['id'],
                title: track['name'],
                artist: track['artists'][0]['name'],
                album: track['album']['name'],
                imageUrl: track['album']['images'].isNotEmpty
                    ? track['album']['images'][0]['url']
                    : '',
                audioUrl: track['preview_url'] ?? '',
                durationInSeconds: (track['duration_ms'] / 1000).round(),
                spotifyUri: track['uri'],
              ),
            )
            .toList();
      }
    } catch (e) {
      print('Error obteniendo canciones del artista: $e');
    }

    return _getMockSongs()
        .where((song) => song.artist.contains(artistId))
        .toList();
  }

  // Obtener playlists destacadas
  Future<List<Playlist>> getFeaturedPlaylists() async {
    final authenticated = await _ensureAuthenticated();
    if (!authenticated) {
      return _getMockPlaylists();
    }

    try {
      final token = await _getAccessToken();
      if (token == null) {
        return _getMockPlaylists();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/browse/featured-playlists?limit=20'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final playlists = data['playlists']['items'] as List;

        List<Playlist> result = [];

        for (var playlist in playlists) {
          // Obtener canciones de cada playlist
          final songs = await _getPlaylistTracks(playlist['id']);

          result.add(
            Playlist(
              id: playlist['id'],
              name: playlist['name'],
              description: playlist['description'] ?? '',
              imageUrl: playlist['images'].isNotEmpty
                  ? playlist['images'][0]['url']
                  : '',
              songs: songs,
            ),
          );
        }

        return result;
      }
    } catch (e) {
      print('Error obteniendo playlists: $e');
    }

    return _getMockPlaylists();
  }

  // Obtener canciones de una playlist
  Future<List<Song>> _getPlaylistTracks(String playlistId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/playlists/$playlistId/tracks?limit=10'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        return items.where((item) => item['track'] != null).map((item) {
          final track = item['track'];
          return SongModel(
            id: track['id'],
            title: track['name'],
            artist: track['artists'][0]['name'],
            album: track['album']['name'],
            imageUrl: track['album']['images'].isNotEmpty
                ? track['album']['images'][0]['url']
                : '',
            audioUrl: track['preview_url'] ?? '',
            durationInSeconds: (track['duration_ms'] / 1000).round(),
            spotifyUri: track['uri'],
          ).toEntity();
        }).toList();
      }
    } catch (e) {
      print('Error obteniendo canciones de playlist: $e');
    }

    return [];
  }

  // Mantener datos mock como fallback con audio funcional
  List<SongModel> _getMockSongs() {
    return [
      // Canciones demo con audio funcional de SoundHelix
      SongModel(
        id: 'demo_1',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours (Demo)',
        imageUrl:
            'https://i.scdn.co/image/ab67616d0000b273ef017e899c0547766997d874',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        durationInSeconds: 200,
        spotifyUri: 'spotify:track:0VjIjW4GlULA4LGGhOdlaP',
      ),
      SongModel(
        id: 'demo_2',
        title: 'Shape of You',
        artist: 'Ed Sheeran',
        album: '÷ (Divide) (Demo)',
        imageUrl:
            'https://i.scdn.co/image/ab67616d0000b273ba5db46f4b838ef6027e6f96',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        durationInSeconds: 235,
        spotifyUri: 'spotify:track:7qiZfU4dY1lWllzX7GqfeM',
      ),
      SongModel(
        id: 'demo_3',
        title: 'Bad Guy',
        artist: 'Billie Eilish',
        album: 'When We All Fall Asleep (Demo)',
        imageUrl:
            'https://i.scdn.co/image/ab67616d0000b2736dc6a2c4bb92e6e8c3b3b0b1',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        durationInSeconds: 194,
        spotifyUri: 'spotify:track:2Fxmhks0bxGSBdJ92vM42m',
      ),
      SongModel(
        id: 'demo_4',
        title: 'Watermelon Sugar',
        artist: 'Harry Styles',
        album: 'Fine Line (Demo)',
        imageUrl:
            'https://i.scdn.co/image/ab67616d0000b2737ac31bd6c42b5c43b2b9b9b1',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        durationInSeconds: 174,
        spotifyUri: 'spotify:track:6UelLqGlWMcVH1E5c4H7lY',
      ),
      SongModel(
        id: 'demo_5',
        title: 'Levitating',
        artist: 'Dua Lipa',
        album: 'Future Nostalgia (Demo)',
        imageUrl:
            'https://i.scdn.co/image/ab67616d0000b273be841ba4bc24b8b5c9b5b5b1',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        durationInSeconds: 203,
        spotifyUri: 'spotify:track:463CkQjx2Zk1yXoBuierM9',
      ),
      SongModel(
        id: 'demo_6',
        title: 'Stay',
        artist: 'The Kid LAROI & Justin Bieber',
        album: 'F*CK LOVE 3 (Demo)',
        imageUrl:
            'https://i.scdn.co/image/ab67616d0000b273e2e9b5b5c9b5b5b1be841ba4',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
        durationInSeconds: 141,
        spotifyUri: 'spotify:track:5PjdY0CKGZdEuoNab3yDmX',
      ),
      SongModel(
        id: 'demo_7',
        title: 'Good 4 U',
        artist: 'Olivia Rodrigo',
        album: 'SOUR (Demo)',
        imageUrl:
            'https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
        durationInSeconds: 178,
        spotifyUri: 'spotify:track:4ZtFanR9U6ndgddUvNcjcG',
      ),
      SongModel(
        id: 'demo_8',
        title: 'As It Was',
        artist: 'Harry Styles',
        album: 'Harrys House (Demo)',
        imageUrl:
            'https://i.scdn.co/image/ab67616d0000b273b46f74097655d7f353caab14',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
        durationInSeconds: 167,
        spotifyUri: 'spotify:track:4Dvkj6JhhA12EX05fT7y2e',
      ),
    ];
  }

  List<Artist> _getMockArtists() {
    return [
      const Artist(
        id: 'The Weeknd',
        name: 'The Weeknd',
        imageUrl:
            'https://i.scdn.co/image/ab6761610000e5eb214f3cf1cbe7139c1e26ffbb',
        followers: 45000000,
        genres: ['Pop', 'R&B'],
      ),
      const Artist(
        id: 'Ed Sheeran',
        name: 'Ed Sheeran',
        imageUrl:
            'https://i.scdn.co/image/ab6761610000e5eb6b80747acfe4e20b71bf2f3c',
        followers: 42000000,
        genres: ['Pop', 'Folk'],
      ),
      // ... resto de artistas mock
    ];
  }

  List<Playlist> _getMockPlaylists() {
    final songs = _getMockSongs().map((m) => m.toEntity()).toList();
    return [
      Playlist(
        id: 'pl1',
        name: 'Today\'s Top Hits',
        description: 'The biggest hits right now',
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
        songs: songs.take(3).toList(),
      ),
      Playlist(
        id: 'pl2',
        name: 'Chill Vibes',
        description: 'Relax and unwind',
        imageUrl:
            'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=300&h=300&fit=crop',
        songs: songs.skip(2).toList(),
      ),
    ];
  }
}
