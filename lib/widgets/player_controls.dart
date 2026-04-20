import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  _buildAlbumArt(provider),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.cancionActual?.titulo ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          provider.cancionActual?.artista ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          provider.cancionActual?.album ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                        ),
                        onPressed: provider.cancionAnterior,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.deepPurple,
                        ),
                        child: IconButton(
                          icon: Icon(
                            provider.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: provider.playPausa,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                        ),
                        onPressed: provider.siguienteCancion,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _formatDuration(provider.currentPosition),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Expanded(
                    child: Slider(
                      value: provider.currentPosition.inSeconds.toDouble(),
                      max: provider.totalDuration.inSeconds.toDouble(),
                      onChanged: (value) {
                        provider.seekTo(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Text(
                    _formatDuration(provider.totalDuration),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: provider.isShuffle ? Colors.deepPurple : Colors.grey,
                    ),
                    onPressed: provider.toggleShuffle,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                      Icons.repeat,
                      color: provider.isRepeat ? Colors.deepPurple : Colors.grey,
                    ),
                    onPressed: provider.toggleRepeat,
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      const Icon(Icons.volume_down, size: 16, color: Colors.grey),
                      SizedBox(
                        width: 100,
                        child: Slider(
                          value: provider.volumen,
                          onChanged: (value) => provider.cambiarVolumen(value),
                          min: 0,
                          max: 1,
                        ),
                      ),
                      const Icon(Icons.volume_up, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlbumArt(AudioProvider provider) {
    if (provider.cancionActual?.portadaBytes != null) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: MemoryImage(provider.cancionActual!.portadaBytes!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade800,
      ),
      child: const Icon(Icons.music_note, size: 30, color: Colors.grey),
    );
  }
}