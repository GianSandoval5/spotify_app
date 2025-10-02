import 'dart:developer';
import 'package:spotify_app/data/services/spotify_web_service.dart' as web;
import 'package:spotify_app/data/services/spotify_service.dart' as sdk;
import 'package:spotify_app/data/services/spotify_auth_service.dart';
import 'package:spotify_app/data/services/simplified_spotify_auth_service.dart';
import 'package:spotify_app/data/services/official_spotify_service.dart';
import 'package:spotify_app/domain/entities/users_models.dart';
import 'package:spotify_app/domain/repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository;
  final web.SpotifyService _spotifyWebService;
  final sdk.SpotifyService _spotifySDKService;

  AuthService({
    required UserRepository userRepository,
    required web.SpotifyService spotifyWebService,
    required sdk.SpotifyService spotifySDKService,
  }) : _userRepository = userRepository,
       _spotifyWebService = spotifyWebService,
       _spotifySDKService = spotifySDKService;

  /// Obtiene el usuario actual
  Future<User?> getCurrentUser() async {
    return await _userRepository.getCurrentUser();
  }

  /// Login con email (simplificado para demo)
  Future<User?> loginWithEmail(String email) async {
    try {
      log('Intentando login con email: $email');

      final user = await _userRepository.loginWithEmailPassword(email, '');
      if (user != null) {
        log('Login exitoso para: ${user.name}');
        return user;
      } else {
        log('Usuario no encontrado');
        return null;
      }
    } catch (e) {
      log('Error en login: $e');
      return null;
    }
  }

  /// Login con Spotify usando OAuth 2.0 completo
  Future<User?> loginWithSpotifyOAuth() async {
    try {
      log('Iniciando login OAuth 2.0 con Spotify...');

      // Intentar primero con LoginActivity
      var authResult = await SpotifyAuthService.loginWithActivity();

      // Si falla, intentar con navegador
      if (authResult == null) {
        log('LoginActivity falló, intentando con navegador...');
        authResult = await SpotifyAuthService.loginWithBrowser();
      }

      // Si ambos métodos nativos fallan, usar URL directa
      if (authResult == null) {
        log('Métodos nativos fallaron, usando OAuth simplificado...');
        final oauthStarted =
            await SimplifiedSpotifyAuthService.loginWithOAuth();
        if (oauthStarted) {
          log(
            'OAuth simplificado iniciado. Usuario debe completar en navegador.',
          );
          // Retornar usuario demo para continuar
          return await _createDemoUserForOAuth();
        }
        log('Todos los métodos de autenticación fallaron');
        return null;
      }

      // Si obtenemos un código, intercambiarlo por token
      if (authResult['type'] == 'CODE') {
        final code = authResult['code'] as String;
        log('Intercambiando código por token...');

        final tokenData = await SpotifyAuthService.exchangeCodeForToken(code);
        if (tokenData == null) {
          log('Error intercambiando código por token');
          return null;
        }

        // Obtener información del usuario con el token
        final spotifyUserData = await _getSpotifyUserWithToken(
          tokenData['access_token'],
        );
        if (spotifyUserData == null) {
          log('No se pudo obtener información del usuario');
          return null;
        }

        // Crear o actualizar usuario en la base de datos local
        final user = await _userRepository.loginWithSpotify(spotifyUserData);
        log('Login OAuth exitoso: ${user?.name}');

        return user;
      }

      log('Respuesta de autenticación no válida');
      return null;
    } catch (e) {
      log('Error en login OAuth con Spotify: $e');
      return null;
    }
  }

  /// Login usando el SDK oficial de Spotify (ejemplo oficial)
  Future<User?> loginWithOfficialSpotifySDK() async {
    try {
      log('Iniciando autenticación con SDK oficial de Spotify...');

      // Usar el servicio oficial basado en el ejemplo
      final result = await OfficialSpotifyService.authenticateComplete();

      if (result['success'] == true) {
        log('Autenticación oficial exitosa');

        // Crear/actualizar usuario con datos de Spotify
        final userData = {
          'id': 'spotify_official_user',
          'display_name': 'Usuario Spotify',
          'email': 'spotify@user.com',
        };

        final user = await _userRepository.loginWithSpotify(userData);
        log('Usuario oficial logueado: ${user?.name}');

        return user;
      } else {
        log('Autenticación oficial falló: ${result['error']}');
        return null;
      }
    } catch (e) {
      log('Error en autenticación oficial: $e');
      return null;
    }
  }

  /// Crear usuario demo cuando OAuth se inicia pero no se completa inmediatamente
  Future<User?> _createDemoUserForOAuth() async {
    try {
      log('Creando usuario demo para OAuth en progreso...');

      // Usar el primer usuario disponible como demo
      final demoUser = await _userRepository.getUserByEmail(
        'giansando2022@gmail.com',
      );
      if (demoUser != null) {
        // Marcar como "conectado" temporalmente
        final updatedUser = demoUser.copyWith(
          isSpotifyConnected: true,
          lastLogin: DateTime.now(),
        );
        await _userRepository.updateUser(updatedUser);

        // Hacer login con este usuario
        await _userRepository.loginWithEmailPassword(
          'giansando2022@gmail.com',
          '',
        );

        log('Usuario demo OAuth configurado: ${demoUser.name}');
        return updatedUser;
      }

      log('No se pudo crear usuario demo para OAuth');
      return null;
    } catch (e) {
      log('Error creando usuario demo OAuth: $e');
      return null;
    }
  }

  /// Login con Spotify (usando Web API - método simplificado)
  Future<User?> loginWithSpotifyWeb() async {
    try {
      log('Iniciando login con Spotify Web API...');

      // Iniciar autenticación con Spotify
      final success = await _spotifyWebService.authenticateWithSpotify();
      if (!success) {
        log('Falló la autenticación con Spotify');
        return null;
      }

      // Esperar a que el usuario complete la autenticación
      // En una implementación real, esto se haría a través de un callback
      await Future.delayed(const Duration(seconds: 2));

      // Obtener información del usuario
      final spotifyUserData = await _spotifyWebService.getCurrentUser();
      if (spotifyUserData == null) {
        log('No se pudo obtener información del usuario de Spotify');
        return null;
      }

      // Crear o actualizar usuario en la base de datos local
      final user = await _userRepository.loginWithSpotify(spotifyUserData);
      log('Login con Spotify exitoso: ${user?.name}');

      return user;
    } catch (e) {
      log('Error en login con Spotify: $e');
      return null;
    }
  }

  /// Obtener información del usuario usando un token de acceso
  Future<Map<String, dynamic>?> _getSpotifyUserWithToken(
    String accessToken,
  ) async {
    try {
      // Usar el web service para obtener información del usuario
      // Temporalmente configurar el token
      await _spotifyWebService.disconnect(); // Limpiar estado anterior

      // Simular que tenemos el token configurado
      // En una implementación real, podrías tener un método en SpotifyService para configurar el token

      // Por ahora, retornar datos simulados basados en la autenticación exitosa
      return {
        'id': 'spotify_user_${DateTime.now().millisecondsSinceEpoch}',
        'display_name': 'Usuario Spotify Autenticado',
        'email': 'usuario@spotify.com',
        'images': [
          {
            'url':
                'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100&h=100&fit=crop',
          },
        ],
      };
    } catch (e) {
      log('Error obteniendo usuario con token: $e');
      return null;
    }
  }

  /// Login con Spotify SDK (requiere app instalada)
  Future<User?> loginWithSpotifySDK() async {
    try {
      log('Intentando conectar con Spotify SDK...');

      final connected = await _spotifySDKService.connectToSpotifyRemote();
      if (!connected) {
        log('No se pudo conectar con Spotify SDK');
        return null;
      }

      // Si la conexión es exitosa, usar el usuario actual o crear uno temporal
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        // Actualizar estado de conexión con Spotify
        final updatedUser = currentUser.copyWith(
          isSpotifyConnected: true,
          lastLogin: DateTime.now(),
        );

        await _userRepository.updateUser(updatedUser);
        log('Usuario actualizado con conexión Spotify SDK');

        return updatedUser;
      } else {
        // Crear usuario temporal si no hay usuario logueado
        log('Creando sesión temporal para Spotify SDK');
        const email = 'gsandoval@flupione.com';
        return await loginWithEmail(email);
      }
    } catch (e) {
      log('Error en login con Spotify SDK: $e');
      return null;
    }
  }

  /// Logout completo
  Future<void> logout() async {
    try {
      log('Cerrando sesión...');

      // Intentar logout OAuth primero
      await SpotifyAuthService.logout();

      // Desconectar servicios de Spotify
      await _spotifyWebService.disconnect();
      if (_spotifySDKService.isConnected) {
        await _spotifySDKService.disconnect();
      }

      // Cerrar sesión local
      await _userRepository.logout();

      log('Sesión cerrada exitosamente');
    } catch (e) {
      log('Error cerrando sesión: $e');
    }
  }

  /// Logout con diálogo para cambiar usuario de Spotify
  Future<bool> logoutWithSpotifyDialog() async {
    try {
      log('Iniciando logout con diálogo de Spotify...');

      final result = await SpotifyAuthService.logoutWithDialog();

      if (result != null) {
        log('Usuario cambió o cerró sesión en Spotify');

        // Limpiar sesión local también
        await _userRepository.logout();

        return true;
      } else {
        log('Logout cancelado por el usuario');
        return false;
      }
    } catch (e) {
      log('Error en logout con diálogo: $e');
      return false;
    }
  }

  /// Verificar si hay usuario logueado
  Future<bool> isLoggedIn() async {
    return await _userRepository.isUserLoggedIn();
  }

  /// Crear nuevo usuario
  Future<User?> createUser({
    required String name,
    required String email,
    String? profileImageUrl,
  }) async {
    try {
      final user = await _userRepository.createUser(
        name: name,
        email: email,
        profileImageUrl: profileImageUrl,
      );

      log('Usuario creado: ${user.name}');
      return user;
    } catch (e) {
      log('Error creando usuario: $e');
      return null;
    }
  }

  /// Intentar conectar con Spotify automáticamente
  Future<bool> tryConnectSpotify() async {
    try {
      log('Intentando conexión automática con Spotify...');

      // Verificar si Spotify está instalado antes de intentar conectar
      final isAppInstalled = await _spotifySDKService.isSpotifyAppInstalled();

      if (isAppInstalled) {
        // Intentar con SDK solo si está instalado
        try {
          final sdkConnected = await _spotifySDKService
              .connectToSpotifyRemote();
          if (sdkConnected) {
            log('Conectado con Spotify SDK');

            // Actualizar usuario actual si existe
            final currentUser = await getCurrentUser();
            if (currentUser != null && !currentUser.isSpotifyConnected) {
              await _userRepository.updateUser(
                currentUser.copyWith(isSpotifyConnected: true),
              );
            }

            return true;
          }
        } catch (e) {
          log('Error específico del SDK: $e');
          // Continuar con Web API como fallback
        }
      } else {
        log('App de Spotify no detectada, usando solo Web API');
      }

      // Intentar con autenticación OAuth completa como alternativa
      log('Intentando con autenticación OAuth completa...');
      try {
        final oauthUser = await loginWithSpotifyOAuth();
        if (oauthUser != null) {
          log('Autenticación OAuth exitosa');
          return true;
        }
      } catch (e) {
        log('Error con OAuth: $e');
      }

      // Como último recurso, intentar Web API simple
      log('Como último recurso, intentando Web API simple...');
      try {
        final webConnected = _spotifyWebService.isConnected;
        if (webConnected) {
          log('Ya conectado con Spotify Web API');
          return true;
        }

        // Si no está conectado, intentar autenticar
        final authResult = await _spotifyWebService.authenticateWithSpotify();
        if (authResult) {
          log('Autenticación Web iniciada exitosamente');
          return true;
        }
      } catch (e) {
        log('Error con Web API: $e');
      }

      log(
        'No se pudo conectar con ningún servicio de Spotify - continuando con datos mock',
      );
      return false;
    } catch (e) {
      log('Error general en conexión con Spotify: $e');
      return false;
    }
  }
}
