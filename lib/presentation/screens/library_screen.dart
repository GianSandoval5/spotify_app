// lib/presentation/screens/library_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spotify_app/domain/entities/song_models.dart';
import 'package:spotify_app/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:spotify_app/presentation/providers/audio_provider.dart';
import 'package:spotify_app/presentation/widgets/spotify_connection_widget.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<FavoritesBloc>().add(LoadFavoritesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF1DB954),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Your Library',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Widget de conexión Spotify
          const SpotifyConnectionWidget(),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFF1DB954),
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[400],
              tabs: const [
                Tab(text: 'Favorites'),
                Tab(text: 'Playlists'),
                Tab(text: 'Artists'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_FavoritesTab(), _PlaylistsTab(), _ArtistsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        if (state is FavoritesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1DB954)),
          );
        }

        if (state is FavoritesLoaded) {
          if (state.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Songs you like will appear here',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Play All Button
              Container(
                margin: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final audioProvider = Provider.of<AudioProvider>(
                            context,
                            listen: false,
                          );
                          audioProvider.playPlaylist(state.favorites);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.shuffle, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),

              // Favorites List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 140),
                  itemCount: state.favorites.length,
                  itemBuilder: (context, index) {
                    final song = state.favorites[index];
                    return _FavoriteSongItem(
                      song: song,
                      index: index,
                      allSongs: state.favorites,
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (state is FavoritesError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _FavoriteSongItem extends StatelessWidget {
  final Song song;
  final int index;
  final List<Song> allSongs;

  const _FavoriteSongItem({
    required this.song,
    required this.index,
    required this.allSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(song.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<FavoritesBloc>().add(RemoveFromFavoritesEvent(song.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${song.title} removed from favorites'),
            backgroundColor: const Color(0xFF282828),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: const Color(0xFF1DB954),
              onPressed: () {
                context.read<FavoritesBloc>().add(AddToFavoritesEvent(song));
              },
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          final audioProvider = Provider.of<AudioProvider>(
            context,
            listen: false,
          );
          audioProvider.playPlaylist(allSongs, initialIndex: index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Album Art
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: song.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Favorite Button
              IconButton(
                icon: const Icon(Icons.favorite, color: Color(0xFF1DB954)),
                onPressed: () {
                  context.read<FavoritesBloc>().add(
                    RemoveFromFavoritesEvent(song.id),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_music, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No playlists yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No artists yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
