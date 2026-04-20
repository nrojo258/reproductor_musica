import 'package:flutter/foundation.dart';

class AudioMetadataService {
  Future<Map<String, dynamic>> extraerMetadatos(String url) async {
    try {
      debugPrint('Extrayendo metadatos de: $url');
      
      return {
        'titulo': '',
        'artista': 'Artista desconocido',
        'album': 'Album desconocido',
        'portada': null,
      };
    } catch (e) {
      debugPrint('Error extrayendo metadatos: $e');
    }
    
    return {
      'titulo': '',
      'artista': 'Artista desconocido',
      'album': 'Album desconocido',
      'portada': null,
    };
  }
}