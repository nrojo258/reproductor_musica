import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

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
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_downward, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Album Art
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withAlpha((0.3 * 255).toInt()),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildAlbumArt(provider),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Song Title
                        Text(
                          provider.cancionActual?.titulo ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        
                        // Artist Name
                        Text(
                          provider.cancionActual?.artista ?? 'Artista desconocido',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Album Name
                        Text(
                          provider.cancionActual?.album ?? 'Álbum desconocido',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Progress Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Slider(
                                value: provider.currentPosition.inSeconds.toDouble(),
                                max: provider.totalDuration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  provider.seekTo(Duration(seconds: value.toInt()));
                                },
                                activeColor: Colors.deepPurple,
                                inactiveColor: Colors.grey.shade800,
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
                        
                        // Playback Controls
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
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.deepPurple,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withAlpha((0.5 * 255).toInt()),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  provider.isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                onPressed: provider.playPausa,
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
                        
                        // Volume Control
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
                        
                        // Favorite Button
                        IconButton(
                          icon: Icon(
                            provider.cancionActual?.esFavorita ?? false
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: (provider.cancionActual?.esFavorita ?? false)
                                ? Colors.deepPurple
                                : Colors.grey,
                            size: 30,
                          ),
                          onPressed: () {
                            if (provider.cancionActual != null) {
                              provider.toggleFavorito(provider.cancionActual!);
                            }
                          },
                        ),
                      ],
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
    // Si tiene imagen de portada, mostrarla
    if (provider.cancionActual?.portadaBytes != null) {
      return Image.memory(
        provider.cancionActual!.portadaBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAlbumArt();
        },
      );
    }
    
    // Si no tiene portada, mostrar diseño por defecto
    return _buildDefaultAlbumArt();
  }

  Widget _buildDefaultAlbumArt() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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