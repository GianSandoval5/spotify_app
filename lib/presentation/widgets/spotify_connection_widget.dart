// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_app/presentation/providers/audio_provider.dart';

class SpotifyConnectionWidget extends StatelessWidget {
  const SpotifyConnectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final isConnected = audioProvider.isSpotifyConnected;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Icono de Spotify
              Icon(
                Icons.music_note,
                color: isConnected ? const Color(0xFF1DB954) : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),

              // Estado de conexión
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isConnected
                          ? 'Spotify Connected'
                          : 'Spotify Disconnected',
                      style: TextStyle(
                        color: isConnected
                            ? const Color(0xFF1DB954)
                            : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (audioProvider.currentSong != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        audioProvider.currentPlayerInfo,
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),

              // Botón de conexión/desconexión
              IconButton(
                icon: Icon(
                  isConnected ? Icons.link_off : Icons.link,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () async {
                  if (isConnected) {
                    await audioProvider.disconnectFromSpotify();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Disconnected from Spotify'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else {
                    final success = await audioProvider.connectToSpotify();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Connected to Spotify!'
                              : 'Failed to connect to Spotify. Make sure Spotify app is installed.',
                        ),
                        backgroundColor: success
                            ? const Color(0xFF1DB954)
                            : Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
