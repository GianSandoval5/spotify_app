class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? spotifyId;
  final bool isSpotifyConnected;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.spotifyId,
    this.isSpotifyConnected = false,
    required this.createdAt,
    this.lastLogin,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? spotifyId,
    bool? isSpotifyConnected,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      spotifyId: spotifyId ?? this.spotifyId,
      isSpotifyConnected: isSpotifyConnected ?? this.isSpotifyConnected,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, isSpotifyConnected: $isSpotifyConnected)';
  }
}