import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cancion.dart';
import '../providers/audio_provider.dart';

class SongTile extends StatelessWidget {
  final Cancion cancion;

  const SongTile({super.key, required this.cancion});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.cancionActual?.id == cancion.id;
        final isPlayingNow = isSelected && provider.isPlaying;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple.withAlpha((0.2 * 255).toInt()) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade900,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: cancion.portadaBytes != null
                    ? Image.memory(
                        cancion.portadaBytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultIcon(isPlayingNow);
                        },
                      )
                    : _buildDefaultIcon(isPlayingNow),
              ),
            ),
            title: Text(
              cancion.titulo,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.deepPurple : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              cancion.artista,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    cancion.esFavorita ? Icons.favorite : Icons.favorite_border,
                    color: cancion.esFavorita ? Colors.deepPurple : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    provider.toggleFavorito(cancion);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          cancion.esFavorita
                              ? 'Añadido a favoritos'
                              : 'Eliminado de favoritos',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  cancion.duracion,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              provider.reproducirCancion(cancion);
            },
          ),
        );
      },
    );
  }

  Widget _buildDefaultIcon(bool isPlayingNow) {
    return Container(
      color: Colors.grey.shade800,
      child: isPlayingNow
          ? const Icon(Icons.equalizer, color: Colors.deepPurple, size: 30)
          : const Icon(Icons.music_note, color: Colors.grey, size: 30),
    );
  }
}