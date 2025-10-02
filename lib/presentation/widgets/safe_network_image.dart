import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SafeNetworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay URL, mostrar widget de error directamente
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: const Color(0xFF282828),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1DB954),
                strokeWidth: 2,
              ),
            ),
          ),
      errorWidget: (context, url, error) {
        // Log del error para debugging
        print('Error cargando imagen: $url - Error: $error');
        return _buildErrorWidget();
      },
      // Configuraciones adicionales para mejor manejo de cache
      cacheManager: null, // Usar cache manager por defecto
      useOldImageOnUrlChange: true,
      filterQuality: FilterQuality.medium,
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1DB954).withValues(alpha: 0.2),
            const Color(0xFF282828),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child:
          errorWidget ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                color: const Color(0xFF1DB954).withValues(alpha: 0.7),
                size: (width != null && height != null)
                    ? (width! < height! ? width! * 0.3 : height! * 0.3)
                    : 40,
              ),
              if (width != null && width! > 100) ...[
                const SizedBox(height: 8),
                Text(
                  'Sin imagen',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ],
          ),
    );
  }
}

// Widget específico para álbumes
class AlbumImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const AlbumImage({super.key, this.imageUrl, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return SafeNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(8),
      errorWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF1DB954).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.album,
          color: const Color(0xFF1DB954).withValues(alpha: 0.7),
          size: size * 0.5,
        ),
      ),
    );
  }
}

// Widget específico para artistas
class ArtistImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ArtistImage({super.key, this.imageUrl, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return SafeNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2), // Circular para artistas
      errorWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF1DB954).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.person,
          color: const Color(0xFF1DB954).withValues(alpha: 0.7),
          size: size * 0.5,
        ),
      ),
    );
  }
}

// Widget específico para playlists
class PlaylistImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const PlaylistImage({super.key, this.imageUrl, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return SafeNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(8),
      errorWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1DB954).withValues(alpha: 0.3),
              const Color(0xFF1DB954).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          Icons.queue_music,
          color: const Color(0xFF1DB954).withValues(alpha: 0.8),
          size: size * 0.5,
        ),
      ),
    );
  }
}
