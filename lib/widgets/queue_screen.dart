import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../models/cancion.dart';
import 'song_tile.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Cola de Reproducción'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () {
              // Reproducir toda la cola desde el principio
              final provider = Provider.of<AudioProvider>(context, listen: false);
              if (provider.colaReproduccion.isNotEmpty) {
                provider.reproducirDesdeCola(0);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              // Limpiar cola
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Limpiar cola'),
                  content: const Text('¿Quieres limpiar toda la cola de reproducción?'),
                  backgroundColor: Colors.grey.shade900,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        final provider = Provider.of<AudioProvider>(context, listen: false);
                        provider.limpiarCola();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Limpiar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          if (provider.colaReproduccion.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue_music, size: 64, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text(
                    'Cola vacía',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Añade canciones desde Explore',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Información de la cola
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade900,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.totalCola} canciones en cola',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Reproduciendo: ${provider.posicionActual}/${provider.totalCola}',
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex--;
                    }
                    provider.moverEnCola(oldIndex, newIndex);
                  },
                  itemCount: provider.colaReproduccion.length,
                  itemBuilder: (context, index) {
                    final cancion = provider.colaReproduccion[index];
                    final esActual = provider.modoReproduccion == 'queue' && 
                                     provider.indiceCola == index;
                    
                    return Container(
                      key: ValueKey(cancion.id),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: esActual ? Colors.deepPurple.withAlpha(51) : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: cancion.portadaBytes != null
                                ? Image.memory(cancion.portadaBytes!, fit: BoxFit.cover)
                                : Icon(Icons.music_note, color: Colors.grey.shade400),
                          ),
                        ),
                        title: Row(
                          children: [
                            if (esActual)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cancion.titulo,
                                    style: TextStyle(
                                      fontWeight: esActual ? FontWeight.bold : FontWeight.normal,
                                      color: esActual ? Colors.deepPurple : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    cancion.artista,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cancion.duracion,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.drag_handle,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () {
                          provider.reproducirDesdeCola(index);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}