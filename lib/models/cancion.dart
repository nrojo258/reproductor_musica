import 'dart:typed_data';

class Cancion {
  final String id;
  final String nombre;
  final String url;
  String titulo;
  String artista;
  String album;
  String duracion;
  String? portadaUrl;
  int duracionSegundos;
  bool esFavorita;
  Uint8List? portadaBytes;

  Cancion({
    required this.id,
    required this.nombre,
    required this.url,
    this.titulo = '',
    this.artista = 'Artista desconocido',
    this.album = 'Album desconocido',
    this.duracion = '00:00',
    this.portadaUrl,
    this.duracionSegundos = 0,
    this.esFavorita = false,
    this.portadaBytes,
  });
}