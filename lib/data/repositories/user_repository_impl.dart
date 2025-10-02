import 'package:hive/hive.dart';
import 'package:spotify_app/data/models/users_models.dart';
import 'package:spotify_app/domain/entities/users_models.dart';
import 'package:spotify_app/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  static const String _boxName = 'users';
  static const String _currentUserKey = 'current_user_id';

  late Box<UserModel> _userBox;
  late Box<String> _sessionBox;

  Future<void> init() async {
    _userBox = await Hive.openBox<UserModel>(_boxName);
    _sessionBox = await Hive.openBox<String>('user_session');

    // Crear usuario por defecto si no existe
    await _createDefaultUserIfNeeded();
  }

  Future<void> _createDefaultUserIfNeeded() async {
    const defaultEmail = 'giansando2022@gmail.com';

    // Verificar si ya existe el usuario por defecto
    final existingUser = await getUserByEmail(defaultEmail);
    if (existingUser == null) {
      final defaultUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Gian Sandoval',
        email: defaultEmail,
        createdAt: DateTime.now(),
        isSpotifyConnected: false,
      );

      await _userBox.put(defaultUser.id, defaultUser);
      print('Usuario por defecto creado: ${defaultUser.name}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final currentUserId = _sessionBox.get(_currentUserKey);
    if (currentUserId == null) return null;

    final userModel = _userBox.get(currentUserId);
    return userModel?.toEntity();
  }

  @override
  Future<User> createUser({
    required String name,
    required String email,
    String? profileImageUrl,
  }) async {
    // Verificar si el usuario ya existe
    final existingUser = await getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('Ya existe un usuario con este email');
    }

    final userModel = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      createdAt: DateTime.now(),
      isSpotifyConnected: false,
    );

    await _userBox.put(userModel.id, userModel);
    return userModel.toEntity();
  }

  @override
  Future<User> updateUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await _userBox.put(userModel.id, userModel);
    return userModel.toEntity();
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _userBox.delete(userId);

    // Si era el usuario actual, cerrar sesión
    final currentUserId = _sessionBox.get(_currentUserKey);
    if (currentUserId == userId) {
      await logout();
    }
  }

  @override
  Future<User?> loginWithEmailPassword(String email, String password) async {
    // Por simplicidad, solo verificamos el email
    // En una app real, verificarías también la contraseña
    final user = await getUserByEmail(email);
    if (user != null) {
      await _sessionBox.put(_currentUserKey, user.id);

      // Actualizar último login
      final updatedUser = user.copyWith(lastLogin: DateTime.now());
      await updateUser(updatedUser);

      return updatedUser;
    }
    return null;
  }

  @override
  Future<User?> loginWithSpotify(Map<String, dynamic> spotifyData) async {
    final spotifyId = spotifyData['id'];

    // Buscar usuario existente con este Spotify ID
    User? existingUser;
    for (final userModel in _userBox.values) {
      if (userModel.spotifyId == spotifyId) {
        existingUser = userModel.toEntity();
        break;
      }
    }

    if (existingUser != null) {
      // Usuario existente, actualizar información
      final updatedUser = existingUser.copyWith(
        name: spotifyData['display_name'] ?? existingUser.name,
        email: spotifyData['email'] ?? existingUser.email,
        profileImageUrl: spotifyData['images']?.isNotEmpty == true
            ? spotifyData['images'][0]['url']
            : existingUser.profileImageUrl,
        isSpotifyConnected: true,
        lastLogin: DateTime.now(),
      );

      await updateUser(updatedUser);
      await _sessionBox.put(_currentUserKey, updatedUser.id);

      return updatedUser;
    } else {
      // Crear nuevo usuario desde datos de Spotify
      final userModel = UserModel.fromSpotifyData(spotifyData);
      await _userBox.put(userModel.id, userModel);
      await _sessionBox.put(_currentUserKey, userModel.id);

      return userModel.toEntity();
    }
  }

  @override
  Future<void> logout() async {
    await _sessionBox.delete(_currentUserKey);
  }

  @override
  Future<bool> isUserLoggedIn() async {
    final currentUserId = _sessionBox.get(_currentUserKey);
    return currentUserId != null && _userBox.containsKey(currentUserId);
  }

  @override
  Future<List<User>> getAllUsers() async {
    return _userBox.values.map((userModel) => userModel.toEntity()).toList();
  }

  @override
  Future<User?> getUserById(String id) async {
    final userModel = _userBox.get(id);
    return userModel?.toEntity();
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    for (final userModel in _userBox.values) {
      if (userModel.email.toLowerCase() == email.toLowerCase()) {
        return userModel.toEntity();
      }
    }
    return null;
  }
}
