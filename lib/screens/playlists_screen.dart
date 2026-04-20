import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../models/cancion.dart';
import '../widgets/song_tile.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
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
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis Playlists',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Tus canciones favoritas organizadas',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPlaylistFolder(
                        context,
                        provider,
                        'Canciones Favoritas',
                        provider.cancionesFavoritas.length,
                        Icons.favorite,
                        Colors.red,
                        () => _showPlaylistSongs(
                          context,
                          provider,
                          'Canciones Favoritas',
                          provider.cancionesFavoritas,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPlaylistFolder(
                        context,
                        provider,
                        'Recientemente Anadidas',
                        provider.canciones.length,
                        Icons.access_time,
                        Colors.green,
                        () => _showPlaylistSongs(
                          context,
                          provider,
                          'Recientemente Anadidas',
                          provider.canciones.reversed.toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPlaylistFolder(
                        context,
                        provider,
                        'Electronic Vibes',
                        0,
                        Icons.electrical_services,
                        Colors.blue,
                        () => _showEmptyPlaylist(context, 'Electronic Vibes'),
                      ),
                      const SizedBox(height: 12),
                      _buildPlaylistFolder(
                        context,
                        provider,
                        'Chill Sessions',
                        0,
                        Icons.beach_access,
                        Colors.cyan,
                        () => _showEmptyPlaylist(context, 'Chill Sessions'),
                      ),
                      const SizedBox(height: 12),
                      _buildPlaylistFolder(
                        context,
                        provider,
                        'Workout Energy',
                        0,
                        Icons.fitness_center,
                        Colors.orange,
                        () => _showEmptyPlaylist(context, 'Workout Energy'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaylistFolder(
    BuildContext context,
    AudioProvider provider,
    String name,
    int songCount,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withAlpha((0.2 * 255).toInt()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '$songCount canciones',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  void _showPlaylistSongs(
    BuildContext context,
    AudioProvider provider,
    String title,
    List<Cancion> canciones,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey),
                Expanded(
                  child: canciones.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No hay canciones en esta playlist',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Agrega canciones a favoritos desde Explore',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: canciones.length,
                          itemBuilder: (context, index) {
                            final cancion = canciones[index];
                            return SongTile(cancion: cancion);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEmptyPlaylist(BuildContext context, String playlistName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.playlist_add, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              playlistName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Playlist vacia',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Proximamente podras agregar canciones manualmente',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}