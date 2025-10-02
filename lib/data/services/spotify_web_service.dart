import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:spotify_app/core/constants/spotify_config.dart';

class SpotifyService {
  static SpotifyService? _instance;
  static SpotifyService get instance => _instance ??= SpotifyService._();
  SpotifyService._();

  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  bool get isConnected => _accessToken != null && !_isTokenExpired();

  bool _isTokenExpired() {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!);
  }

  /// Inicia el flujo de autenticación OAuth2 con Spotify
  Future<bool> authenticateWithSpotify() async {
    try {
      final scopes = SpotifyConfig.scopes.join('%20');
      final authUrl =
          'https://accounts.spotify.com/authorize'
          '?client_id=${SpotifyConfig.clientId}'
          '&response_type=code'
          '&redirect_uri=${Uri.encodeComponent(SpotifyConfig.redirectUri)}'
          '&scope=$scopes'
          '&show_dialog=true';

      log('Abriendo URL de autenticación: $authUrl');

      if (await canLaunchUrl(Uri.parse(authUrl))) {
        await launchUrl(
          Uri.parse(authUrl),
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        log('No se puede abrir la URL de autenticación');
        return false;
      }
    } catch (e) {
      log('Error en autenticación: $e');
      return false;
    }
  }

  /// Intercambia el código de autorización por un token de acceso
  Future<bool> exchangeCodeForToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${SpotifyConfig.clientId}:${SpotifyConfig.clientSecret}'))}',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': SpotifyConfig.redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];

        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        log('Token obtenido exitosamente');
        return true;
      } else {
        log(
          'Error obteniendo token: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      log('Error intercambiando código por token: $e');
      return false;
    }
  }

  /// Refresca el token de acceso usando el refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${SpotifyConfig.clientId}:${SpotifyConfig.clientSecret}'))}',
        },
        body: {'grant_type': 'refresh_token', 'refresh_token': _refreshToken!},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];

        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        log('Token refrescado exitosamente');
        return true;
      } else {
        log('Error refrescando token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error refrescando token: $e');
      return false;
    }
  }

  /// Obtiene información del usuario actual
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (!isConnected) return null;

    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Token expirado, intentar refrescar
        if (await refreshAccessToken()) {
          return await getCurrentUser();
        }
      }
    } catch (e) {
      log('Error obteniendo usuario actual: $e');
    }
    return null;
  }

  /// Busca canciones en Spotify
  Future<List<Map<String, dynamic>>> searchTracks(
    String query, {
    int limit = 20,
  }) async {
    if (!isConnected) return [];

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(
        Uri.parse(
          'https://api.spotify.com/v1/search?q=$encodedQuery&type=track&limit=$limit',
        ),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks']['items'] as List;
        return tracks.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        // Token expirado, intentar refrescar
        if (await refreshAccessToken()) {
          return await searchTracks(query, limit: limit);
        }
      }
    } catch (e) {
      log('Error buscando canciones: $e');
    }
    return [];
  }

  /// Obtiene las playlists del usuario
  Future<List<Map<String, dynamic>>> getUserPlaylists({int limit = 20}) async {
    if (!isConnected) return [];

    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/playlists?limit=$limit'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final playlists = data['items'] as List;
        return playlists.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        if (await refreshAccessToken()) {
          return await getUserPlaylists(limit: limit);
        }
      }
    } catch (e) {
      log('Error obteniendo playlists: $e');
    }
    return [];
  }

  /// Desconecta y limpia los tokens
  Future<void> disconnect() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    log('Desconectado de Spotify');
  }

  // Métodos placeholder para compatibilidad con el player híbrido
  Future<bool> connectToSpotifyRemote() async {
    return await authenticateWithSpotify();
  }

  Future<bool> play(String spotifyUri) async {
    log('Reproducir con Spotify Web API no está soportado directamente');
    log('URI: $spotifyUri');
    // La API Web de Spotify requiere que tengas un dispositivo activo
    // Para reprodución necesitarías usar el SDK nativo o la Web Playback SDK
    return false;
  }

  Future<bool> pause() async {
    log('Pausar con Spotify Web API requiere dispositivo activo');
    return false;
  }

  Future<bool> resume() async {
    log('Reanudar con Spotify Web API requiere dispositivo activo');
    return false;
  }

  Future<bool> skipNext() async {
    log('Siguiente canción con Spotify Web API requiere dispositivo activo');
    return false;
  }

  Future<bool> skipPrevious() async {
    log('Canción anterior con Spotify Web API requiere dispositivo activo');
    return false;
  }

  Future<dynamic> getPlayerState() async {
    log(
      'Estado del reproductor con Spotify Web API requiere dispositivo activo',
    );
    return null;
  }

  Stream<dynamic> get playerStateStream {
    return Stream.empty();
  }

  Future<bool> isSpotifyAppInstalled() async {
    return true; // La API web siempre está disponible
  }
}
