// lib/presentation/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spotify_app/domain/entities/song_models.dart';
import 'package:spotify_app/presentation/bloc/music/music_bloc.dart';
import 'package:spotify_app/presentation/bloc/music/music_event.dart';
import 'package:spotify_app/presentation/bloc/music/music_state.dart';
import 'package:spotify_app/presentation/providers/audio_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _isSearching = false);
      return;
    }

    setState(() => _isSearching = true);
    context.read<MusicBloc>().add(SearchSongsEvent(query));
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF1DB954)),
            SizedBox(width: 8),
            Text(
              'Cómo reproducir música',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          '🔵 PREVIEW (Azul): Se reproduce inmediatamente con audio de 30 segundos.\n\n'
          '🟠 SDK ONLY (Naranja): Requiere que tengas Spotify abierto en tu teléfono para reproducir la canción completa.\n\n'
          '✨ DEMO: Canciones de demostración que siempre funcionan.\n\n'
          '💡 TIP: Busca canciones populares, suelen tener preview disponible.',
          style: TextStyle(color: Colors.white, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'What do you want to listen to?',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _isSearching = false);
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón de ayuda
                IconButton(
                  onPressed: _showHelpDialog,
                  icon: const Icon(
                    Icons.help_outline,
                    color: Color(0xFF1DB954),
                  ),
                  tooltip: 'Ayuda sobre reproducción',
                ),
              ],
            ),
          ),

          // Search Results or Categories
          Expanded(
            child: _isSearching
                ? BlocBuilder<MusicBloc, MusicState>(
                    builder: (context, state) {
                      if (state is MusicLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1DB954),
                          ),
                        );
                      }

                      if (state is SearchResultsLoaded) {
                        if (state.songs.isEmpty) {
                          return Center(
                            child: Text(
                              'No results found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            // Header informativo
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF282828),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF1DB954,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Color(0xFF1DB954),
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Cómo reproducir canciones',
                                        style: TextStyle(
                                          color: Color(0xFF1DB954),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '🔵 Preview: Audio de 30 segundos disponible inmediatamente\n'
                                    '🟠 SDK only: Requiere Spotify abierto para reproducir completa',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Lista de resultados
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 140),
                                itemCount: state.songs.length,
                                itemBuilder: (context, index) {
                                  final song = state.songs[index];
                                  return _SearchResultItem(song: song);
                                },
                              ),
                            ),
                          ],
                        );
                      }

                      if (state is MusicError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  )
                : _BrowseCategories(),
          ),
        ],
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final Song song;

  const _SearchResultItem({required this.song});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final audioProvider = Provider.of<AudioProvider>(
          context,
          listen: false,
        );
        audioProvider.playSong(song);
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Indicador de preview
                      if (song.audioUrl.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            border: Border.all(color: Colors.blue, width: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Preview',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.orange,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SDK only',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${song.artist} • ${song.album}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // More Options
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {
                _showSongOptions(context, song);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.white),
              title: const Text(
                'Add to Favorites',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Add to favorites logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text(
                'Add to Playlist',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowseCategories extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Pop', 'color': const Color(0xFFDC148C), 'icon': Icons.music_note},
    {'name': 'Rock', 'color': const Color(0xFF8D67AB), 'icon': Icons.album},
    {
      'name': 'Hip-Hop',
      'color': const Color(0xFFBC5900),
      'icon': Icons.headphones,
    },
    {
      'name': 'Electronic',
      'color': const Color(0xFF1E3264),
      'icon': Icons.surround_sound,
    },
    {
      'name': 'Latin',
      'color': const Color(0xFFE8115B),
      'icon': Icons.music_video,
    },
    {'name': 'Jazz', 'color': const Color(0xFF477D95), 'icon': Icons.piano},
  ];

  _BrowseCategories();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Text(
            'Browse all',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryCard(
                name: category['name'],
                color: category['color'],
                icon: category['icon'],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;

  const _CategoryCard({
    required this.name,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 12,
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: Transform.rotate(
              angle: 0.4,
              child: Icon(
                icon,
                size: 80,
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
