import 'package:spotify_app/domain/entities/users_models.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User> createUser({
    required String name,
    required String email,
    String? profileImageUrl,
  });
  Future<User> updateUser(User user);
  Future<void> deleteUser(String userId);
  Future<User?> loginWithEmailPassword(String email, String password);
  Future<User?> loginWithSpotify(Map<String, dynamic> spotifyData);
  Future<void> logout();
  Future<bool> isUserLoggedIn();
  Future<List<User>> getAllUsers();
  Future<User?> getUserById(String id);
  Future<User?> getUserByEmail(String email);
}