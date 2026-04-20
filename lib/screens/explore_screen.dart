import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sonic Ether',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        'Premium Audio',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar canciones...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: provider.filtroTexto.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () => provider.limpiarFiltro(),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => provider.filtrarCanciones(value),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${provider.canciones.length} canciones',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      if (provider.canciones.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            provider.reproducirCancion(provider.canciones[0]);
                          },
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Reproducir todo'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.canciones.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    provider.filtroTexto.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.music_off,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    provider.filtroTexto.isNotEmpty
                                        ? 'No se encontraron canciones'
                                        : 'No hay canciones disponibles',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: provider.canciones.length,
                              itemBuilder: (context, index) {
                                final cancion = provider.canciones[index];
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
}