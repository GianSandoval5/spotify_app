import 'package:flutter/material.dart';
import 'package:spotify_app/data/services/auth_service.dart';
import 'package:spotify_app/domain/entities/users_models.dart';
import 'package:spotify_app/injection_container.dart';

class UserStatusWidget extends StatefulWidget {
  const UserStatusWidget({super.key});

  @override
  State<UserStatusWidget> createState() => _UserStatusWidgetState();
}

class _UserStatusWidgetState extends State<UserStatusWidget> {
  final _authService = sl<AuthService>();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DB954)),
      );
    }

    if (_currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'No conectado',
              style: TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(color: Color(0xFF1DB954)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1DB954),
            backgroundImage: _currentUser!.profileImageUrl != null
                ? NetworkImage(_currentUser!.profileImageUrl!)
                : null,
            child: _currentUser!.profileImageUrl == null
                ? Text(
                    _currentUser!.name.isNotEmpty 
                        ? _currentUser!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentUser!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      _currentUser!.isSpotifyConnected 
                          ? Icons.music_note 
                          : Icons.music_off,
                      size: 14,
                      color: _currentUser!.isSpotifyConnected 
                          ? const Color(0xFF1DB954) 
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentUser!.isSpotifyConnected 
                          ? 'Conectado a Spotify' 
                          : 'Spotify desconectado',
                      style: TextStyle(
                        color: _currentUser!.isSpotifyConnected 
                            ? const Color(0xFF1DB954) 
                            : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 16),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}