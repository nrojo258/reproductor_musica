import 'package:flutter/foundation.dart';

class AudioMetadataService {
  Future<Map<String, dynamic>> extraerMetadatos(String url) async {
    try {
      return {
        'titulo': '',
        'artista': 'Artista desconocido',
        'album': 'Album desconocido',
        'portada': null,
      };
    } catch (e) {
    }

    return {
      'titulo': '',
      'artista': 'Artista desconocido',
      'album': 'Album desconocido',
      'portada': null,
    };
  }
}