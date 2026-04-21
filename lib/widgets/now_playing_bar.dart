import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import 'full_player_screen.dart';
import 'queue_screen.dart';

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        if (provider.cancionActual == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FullPlayerScreen(),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade800,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildAlbumArt(provider),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (provider.modoReproduccion == 'queue')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${provider.posicionActual}/${provider.totalCola}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    provider.cancionActual?.titulo ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              provider.cancionActual?.artista ?? 'Artista desconocido',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              provider.cancionActual?.esFavorita ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: (provider.cancionActual?.esFavorita ?? false)
                                  ? Colors.deepPurple
                                  : Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              if (provider.cancionActual != null) {
                                provider.toggleFavorito(provider.cancionActual!);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.queue_music, size: 20),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QueueScreen(),
                                ),
                              );
                            },
                            color: provider.modoReproduccion == 'queue'
                                ? Colors.deepPurple
                                : Colors.white,
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            onPressed: provider.cancionAnterior,
                            color: Colors.white,
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepPurple,
                            ),
                            child: IconButton(
                              icon: Icon(
                                provider.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: provider.playPausa,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            onPressed: provider.siguienteCancion,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(
                    value: provider.totalDuration.inSeconds > 0
                        ? provider.currentPosition.inSeconds / provider.totalDuration.inSeconds
                        : 0,
                    backgroundColor: Colors.grey.shade800,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArt(AudioProvider provider) {
    if (provider.cancionActual?.portadaBytes != null) {
      return Image.memory(
        provider.cancionActual!.portadaBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
      );
    }

    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: Colors.grey.shade800,
      child: const Icon(
        Icons.music_note,
        color: Colors.white54,
        size: 30,
      ),
    );
  }
}