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

  Cancion copyWith({
    String? id,
    String? nombre,
    String? url,
    String? titulo,
    String? artista,
    String? album,
    String? duracion,
    String? portadaUrl,
    int? duracionSegundos,
    bool? esFavorita,
    Uint8List? portadaBytes,
  }) {
    return Cancion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      url: url ?? this.url,
      titulo: titulo ?? this.titulo,
      artista: artista ?? this.artista,
      album: album ?? this.album,
      duracion: duracion ?? this.duracion,
      portadaUrl: portadaUrl ?? this.portadaUrl,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      esFavorita: esFavorita ?? this.esFavorita,
      portadaBytes: portadaBytes ?? this.portadaBytes,
    );
  }
}