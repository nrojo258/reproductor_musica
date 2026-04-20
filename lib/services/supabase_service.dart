import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cancion.dart';
import '../config/artistas_config.dart';

class SupabaseService {
  Future<List<Cancion>> obtenerCanciones() async {
    try {
      final supabase = Supabase.instance.client;
      
      debugPrint('📡 Conectando a Supabase Storage...');
      
      final files = await supabase.storage.from('audio').list(
        limit: 100, 
      );
      
      debugPrint('📁 Total archivos encontrados: ${files.length}');
      
      for (var file in files) {
        debugPrint('   - ${file.name} (${file.size} bytes)');
      }
      
      if (files.isEmpty) {
        debugPrint('⚠️ No hay archivos en el bucket "audio"');
        return [];
      }
      
      List<Cancion> canciones = [];
      
      for (var file in files) {
        if (file.name.toLowerCase().endsWith('.mp3')) {
          debugPrint('\n🎵 Procesando MP3: ${file.name}');
          
          final publicUrl = supabase.storage.from('audio').getPublicUrl(file.name);
          debugPrint('🔗 URL pública: $publicUrl');
          
          final metadatosConfig = ArtistasConfig.artistas[file.name];
          
          String titulo = '';
          String artista = 'Artista desconocido';
          String album = 'Álbum desconocido';
          String? portadaPath;
          
          if (metadatosConfig != null) {
            titulo = metadatosConfig['titulo'] ?? '';
            artista = metadatosConfig['artista'] ?? 'Artista desconocido';
            album = metadatosConfig['album'] ?? 'Álbum desconocido';
            portadaPath = metadatosConfig['portada'];
            debugPrint('✅ Metadatos encontrados en artistas_config.dart');
          } else {
            titulo = file.name
                .replaceAll('.mp3', '')
                .replaceAll('_', ' ')
                .replaceAll('-', ' ');
            debugPrint('⚠️ No hay metadatos para ${file.name}, usando nombre del archivo');
          }
          
          debugPrint('   📝 Título final: $titulo');
          debugPrint('   🎤 Artista: $artista');
          
          Cancion cancion = Cancion(
            id: file.name,
            nombre: file.name,
            url: publicUrl,
            titulo: titulo,
            artista: artista,
            album: album,
            portadaUrl: portadaPath,
          );
          
          if (portadaPath != null && portadaPath.isNotEmpty) {
            final imageBytes = await _cargarImagenLocal(portadaPath);
            if (imageBytes != null) {
              cancion.portadaBytes = imageBytes;
              debugPrint('✅ Portada cargada: ${portadaPath}');
            }
          }
          
          canciones.add(cancion);
          debugPrint('✅ Canción agregada a la lista: ${cancion.titulo}');
        } else {
          debugPrint('📄 Ignorando archivo no-MP3: ${file.name}');
        }
      }
      
      debugPrint('\n📊 RESUMEN FINAL:');
      debugPrint('   Total canciones MP3 encontradas: ${canciones.length}');
      for (var cancion in canciones) {
        debugPrint('   - ${cancion.titulo} (${cancion.artista})');
      }
      
      return canciones;
      
    } catch (e) {
      debugPrint('❌ Error al cargar canciones: $e');
      return [];
    }
  }
  
  Future<Uint8List?> _cargarImagenLocal(String path) async {
    try {
      debugPrint('🔍 Buscando imagen: $path');
      final ByteData data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List();
      debugPrint('✅ Imagen cargada: ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      debugPrint('❌ Error cargando imagen $path: $e');
      return null;
    }
  }
}