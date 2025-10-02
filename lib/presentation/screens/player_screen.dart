import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:spotify_app/presentation/providers/audio_provider.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Color _dominantColor = const Color(0xFF282828);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _controller.forward();
    _extractColors();
  }

  Future<void> _extractColors() async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final imageUrl = audioProvider.currentSong?.imageUrl;
    
    if (imageUrl != null) {
      try {
        final paletteGenerator = await PaletteGenerator.fromImageProvider(
          CachedNetworkImageProvider(imageUrl),
        );
        
        if (mounted) {
          setState(() {
            _dominantColor = paletteGenerator.dominantColor?.color ??
                const Color(0xFF282828);
          });
        }
      } catch (e) {
        print('Error extracting colors: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _dominantColor,
              const Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AudioProvider>(
            builder: (context, audioProvider, child) {
              final currentSong = audioProvider.currentSong;
              
              if (currentSong == null) {
                return const Center(
                  child: Text(
                    'No song playing',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 32),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Column(
                          children: [
                            const Text(
                              'PLAYING FROM',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              currentSong.album,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Album Art
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Hero(
                        tag: 'album_art_${currentSong.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: currentSong.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF1DB954),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Song Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentSong.artist,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        BlocBuilder<FavoritesBloc, FavoritesState>(
                          builder: (context, state) {
                            bool isFavorite = false;
                            if (state is FavoritesLoaded) {
                              isFavorite = state.favorites
                                  .any((s) => s.id == currentSong.id);
                            }
                            
                            return IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? const Color(0xFF1DB954)
                                    : Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                if (isFavorite) {
                                  context.read<FavoritesBloc>().add(
                                        RemoveFromFavoritesEvent(currentSong.id),
                                      );
                                } else {
                                  context.read<FavoritesBloc>().add(
                                        AddToFavoritesEvent(currentSong),
                                      );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: StreamBuilder<Duration>(
                      stream: audioProvider.audioService.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = currentSong.duration;
                        
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 14,
                                ),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.grey[800],
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: position.inSeconds.toDouble(),
                                max: duration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  audioProvider.seek(
                                    Duration(seconds: value.toInt()),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            audioProvider.isShuffleEnabled
                                ? Icons.shuffle_on_outlined
                                : Icons.shuffle,
                            color: audioProvider.isShuffleEnabled
                                ? const Color(0xFF1DB954)
                                : Colors.grey[400],
                          ),
                          iconSize: 24,
                          onPressed: () => audioProvider.toggleShuffle(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white),
                          iconSize: 36,
                          onPressed: () => audioProvider.skipToPrevious(),
                        ),
                        StreamBuilder<bool>(
                          stream: audioProvider.audioService.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            
                            return Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.black,
                                ),
                                iconSize: 32,
                                onPressed: () {
                                  if (isPlaying) {
                                    audioProvider.pause();
                                  } else {
                                    audioProvider.play();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white),
                          iconSize: 36,
                          onPressed: () => audioProvider.skipToNext(),
                        ),
                        IconButton(
                          icon: Icon(
                            audioProvider.loopMode == LoopMode.off
                                ? Icons.repeat
                                : audioProvider.loopMode == LoopMode.all
                                    ? Icons.repeat_on
                                    : Icons.repeat_one_on,
                            color: audioProvider.loopMode != LoopMode.off
                                ? const Color(0xFF1DB954)
                                : Colors.grey[400],
                          ),
                          iconSize: 24,
                          onPressed: () => audioProvider.toggleLoopMode(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}