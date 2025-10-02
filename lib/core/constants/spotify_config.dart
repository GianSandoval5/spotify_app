class SpotifyConfig {
  static const String clientId = '2290d5d854e549bd8f43a459948a42fc';
  static const String clientSecret = '2e1fb8005e3b43e2b4710e29a10d1c0c';
  
  // Para SDK nativo (siguiendo documentación oficial)
  static const String redirectUri = 'spotify-sdk://auth';

  // Scopes OAuth para Web API
  static const List<String> oauthScopes = [
    'user-read-private',
    'user-read-email',
    'user-read-playback-state',
    'user-modify-playback-state',
    'user-read-currently-playing',
    'streaming',
  ];

  // Scopes para SDK directo (según documentación)
  static const List<String> scopes = [
    'app-remote-control',
    'user-modify-playback-state',
    'user-read-playback-state',
    'user-read-currently-playing',
  ];
}