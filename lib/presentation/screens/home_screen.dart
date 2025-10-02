// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spotify_app/data/services/notification_service.dart';
import 'package:spotify_app/presentation/bloc/music/music_bloc.dart';
import 'package:spotify_app/presentation/bloc/music/music_event.dart';
import 'package:spotify_app/presentation/bloc/music/music_state.dart';
import 'package:spotify_app/presentation/providers/audio_provider.dart';
import 'package:spotify_app/presentation/screens/library_screen.dart';
import 'package:spotify_app/presentation/screens/search_screen.dart';
import 'package:spotify_app/presentation/widgets/mini_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<MusicBloc>().add(GetFeaturedPlaylistsEvent());

    // Inicializar servicio de notificaciones con el contexto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.setContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeContent(),
      const SearchScreen(),
      const LibraryScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          screens[_selectedIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniPlayer(),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    border: Border(top: BorderSide(color: Colors.grey[900]!)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home, 'Home', 0),
                      _buildNavItem(Icons.search, 'Search', 1),
                      _buildNavItem(Icons.library_music, 'Your Library', 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFF121212),
            title: const Text(
              'Good evening',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(icon: const Icon(Icons.access_time), onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 140),
            sliver: BlocBuilder<MusicBloc, MusicState>(
              builder: (context, state) {
                if (state is MusicLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1DB954),
                      ),
                    ),
                  );
                }

                if (state is FeaturedPlaylistsLoaded) {
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Quick Access Grid
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 3.2,
                              ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            if (index < state.playlists.length) {
                              final playlist = state.playlists[index];
                              return _QuickAccessCard(
                                imageUrl: playlist.imageUrl,
                                title: playlist.name,
                                onTap: () {
                                  final audioProvider =
                                      Provider.of<AudioProvider>(
                                        context,
                                        listen: false,
                                      );
                                  audioProvider.playPlaylist(playlist.songs);
                                },
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),

                      // Featured Playlists
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'Featured Playlists',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = state.playlists[index];
                            return _PlaylistCard(
                              imageUrl: playlist.imageUrl,
                              title: playlist.name,
                              description: playlist.description,
                              onTap: () {
                                final audioProvider =
                                    Provider.of<AudioProvider>(
                                      context,
                                      listen: false,
                                    );
                                audioProvider.playPlaylist(playlist.songs);
                              },
                            );
                          },
                        ),
                      ),

                      // Recently Played Section
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'Recently Played',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.playlists.isNotEmpty
                              ? state.playlists[0].songs.length
                              : 0,
                          itemBuilder: (context, index) {
                            if (state.playlists.isEmpty) {
                              return const SizedBox();
                            }
                            final song = state.playlists[0].songs[index];
                            return _PlaylistCard(
                              imageUrl: song.imageUrl,
                              title: song.title,
                              description: song.artist,
                              onTap: () {
                                final audioProvider =
                                    Provider.of<AudioProvider>(
                                      context,
                                      listen: false,
                                    );
                                audioProvider.playSong(song);
                              },
                            );
                          },
                        ),
                      ),
                    ]),
                  );
                }

                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No content available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.imageUrl,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[800]),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _PlaylistCard({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1DB954)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
