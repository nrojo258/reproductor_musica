import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import 'queue_screen.dart';

class FullPlayerScreen extends StatelessWidget {
  const FullPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          if (provider.cancionActual == null) {
            return const Center(
              child: Text('No hay canción seleccionada'),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade900,
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_downward, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.queue_music,
                                color: provider.modoReproduccion == 'queue'
                                    ? Colors.deepPurple
                                    : Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const QueueScreen(),
                                  ),
                                );
                              },
                            ),
                            if (provider.modoReproduccion == 'queue')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${provider.posicionActual}/${provider.totalCola}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: provider.isPlaying ? 300 : 280,
                              height: provider.isPlaying ? 300 : 280,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withAlpha(provider.isPlaying ? 127 : 76),
                                    blurRadius: provider.isPlaying ? 40 : 30,
                                    spreadRadius: provider.isPlaying ? 10 : 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: _buildAlbumArt(provider),
                              ),
                            ),
                            const SizedBox(height: 40),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                provider.cancionActual?.titulo ?? '',
                                key: ValueKey(provider.cancionActual?.titulo),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.cancionActual?.artista ?? 'Artista desconocido',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.cancionActual?.album ?? 'Álbum desconocido',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  if (provider.totalDuration.inSeconds > 0)
                                    Slider(
                                      value: provider.currentPosition.inSeconds.toDouble().clamp(0.0, provider.totalDuration.inSeconds.toDouble()),
                                      max: provider.totalDuration.inSeconds.toDouble(),
                                      onChanged: (value) {
                                        provider.seekTo(Duration(seconds: value.toInt()));
                                      },
                                      activeColor: Colors.deepPurple,
                                      inactiveColor: Colors.grey.shade800,
                                    )
                                  else
                                    const Slider(
                                      value: 0,
                                      max: 1,
                                      onChanged: null,
                                      activeColor: Colors.deepPurple,
                                      inactiveColor: Colors.grey,
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(provider.currentPosition),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          _formatDuration(provider.totalDuration),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.shuffle,
                                    size: 28,
                                    color: provider.isShuffle ? Colors.deepPurple : Colors.grey,
                                  ),
                                  onPressed: provider.toggleShuffle,
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  icon: const Icon(Icons.skip_previous, size: 40),
                                  onPressed: provider.cancionAnterior,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: () {
                                    provider.playPausa();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.deepPurple,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withAlpha(provider.isPlaying ? 200 : 127),
                                          blurRadius: provider.isPlaying ? 30 : 20,
                                          spreadRadius: provider.isPlaying ? 8 : 5,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          provider.isPlaying ? Icons.pause : Icons.play_arrow,
                                          key: ValueKey(provider.isPlaying),
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  icon: const Icon(Icons.skip_next, size: 40),
                                  onPressed: provider.siguienteCancion,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  icon: Icon(
                                    Icons.repeat,
                                    size: 28,
                                    color: provider.isRepeat ? Colors.deepPurple : Colors.grey,
                                  ),
                                  onPressed: provider.toggleRepeat,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Row(
                                children: [
                                  const Icon(Icons.volume_down, color: Colors.grey, size: 20),
                                  Expanded(
                                    child: Slider(
                                      value: provider.volumen,
                                      onChanged: (value) => provider.cambiarVolumen(value),
                                      min: 0,
                                      max: 1,
                                      activeColor: Colors.deepPurple,
                                      inactiveColor: Colors.grey.shade800,
                                    ),
                                  ),
                                  const Icon(Icons.volume_up, color: Colors.grey, size: 20),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            IconButton(
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  provider.cancionActual?.esFavorita ?? false
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  key: ValueKey(provider.cancionActual?.esFavorita),
                                  color: (provider.cancionActual?.esFavorita ?? false)
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                  size: 30,
                                ),
                              ),
                              onPressed: () {
                                if (provider.cancionActual != null) {
                                  provider.toggleFavorito(provider.cancionActual!);
                                }
                              },
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumArt(AudioProvider provider) {
    if (provider.cancionActual?.portadaBytes != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Image.memory(
          provider.cancionActual!.portadaBytes!,
          key: ValueKey(provider.cancionActual?.portadaBytes),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAlbumArt();
          },
        ),
      );
    }

    return _buildDefaultAlbumArt();
  }

  Widget _buildDefaultAlbumArt() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple,
            Colors.purple,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.album,
          size: 80,
          color: Colors.white54,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}