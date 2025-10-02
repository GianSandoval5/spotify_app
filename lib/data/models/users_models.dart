import 'package:hive/hive.dart';
import 'package:spotify_app/domain/entities/users_models.dart';

part 'users_models.g.dart';

@HiveType(typeId: 3)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? profileImageUrl;

  @HiveField(4)
  String? spotifyId;

  @HiveField(5)
  bool isSpotifyConnected;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.spotifyId,
    this.isSpotifyConnected = false,
    required this.createdAt,
    this.lastLogin,
  });

  // Convertir de entity a model
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      profileImageUrl: user.profileImageUrl,
      spotifyId: user.spotifyId,
      isSpotifyConnected: user.isSpotifyConnected,
      createdAt: user.createdAt,
      lastLogin: user.lastLogin,
    );
  }

  // Convertir de model a entity
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      spotifyId: spotifyId,
      isSpotifyConnected: isSpotifyConnected,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }

  // Para crear un usuario desde datos de Spotify
  factory UserModel.fromSpotifyData(Map<String, dynamic> spotifyData) {
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: spotifyData['display_name'] ?? 'Usuario Spotify',
      email: spotifyData['email'] ?? '',
      profileImageUrl: spotifyData['images']?.isNotEmpty == true 
          ? spotifyData['images'][0]['url'] 
          : null,
      spotifyId: spotifyData['id'],
      isSpotifyConnected: true,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, isSpotifyConnected: $isSpotifyConnected)';
  }
}