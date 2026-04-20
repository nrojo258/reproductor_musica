import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cancion.dart';
import '../config/artistas_config.dart';

class SupabaseService {
  Future<List<Cancion>> obtenerCanciones() async {
    try {
      final supabase = Supabase.instance.client;

      final files = await supabase.storage.from('audio').list();

      if (files.isEmpty) {
        return [];
      }

      List<Cancion> canciones = [];

      for (var file in files) {
        if (file.name.toLowerCase().endsWith('.mp3')) {

          final publicUrl = supabase.storage.from('audio').getPublicUrl(file.name);

          final metadatosConfig = ArtistasConfig.artistas[file.name];

          String titulo = '';
          String artista = 'Artista desconocido';
          String album = 'Álbum desconocido';
          String? portadaPath;
          String duracion = '00:00';

          if (metadatosConfig != null) {
            titulo = metadatosConfig['titulo'] ?? '';
            artista = metadatosConfig['artista'] ?? 'Artista desconocido';
            album = metadatosConfig['album'] ?? 'Álbum desconocido';
            portadaPath = metadatosConfig['portada'];
            duracion = metadatosConfig['duracion'] ?? '00:00';
          } else {
            titulo = file.name
                .replaceAll('.mp3', '')
                .replaceAll('_', ' ')
                .replaceAll('-', ' ');
          }

          Cancion cancion = Cancion(
            id: file.name,
            nombre: file.name,
            url: publicUrl,
            titulo: titulo,
            artista: artista,
            album: album,
            portadaUrl: portadaPath,
            duracion: duracion,
          );

          if (portadaPath != null && portadaPath.isNotEmpty) {
            final imageBytes = await _cargarImagenLocal(portadaPath);
            if (imageBytes != null) {
              cancion.portadaBytes = imageBytes;
            }
          }

          canciones.add(cancion);
        }
      }

      return canciones;

    } catch (e) {
      print('Error al obtener canciones: $e');
      return [];
    }
  }

  Future<Uint8List?> _cargarImagenLocal(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List();
      return bytes;
    } catch (e) {
      print('Error al cargar imagen: $e');
      return null;
    }
  }
}