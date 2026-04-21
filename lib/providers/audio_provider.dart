import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/cancion.dart';
import '../services/supabase_service.dart';

class AudioProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Cancion> _canciones = [];
  List<Cancion> _cancionesFiltradas = [];
  List<Cancion> _cancionesFavoritas = [];
  List<Cancion> _colaReproduccion = [];
  int _indiceCola = 0;
  
  Cancion? _cancionActual;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isRepeat = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volumen = 1.0;
  String _filtroTexto = '';
  int _indiceActual = 0;
  String _seccionActual = 'explore';
  String _modoReproduccion = 'list';

  List<Cancion> get canciones => _cancionesFiltradas;
  List<Cancion> get cancionesFavoritas => _cancionesFavoritas;
  Cancion? get cancionActual => _cancionActual;
  bool get isPlaying => _isPlaying;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;
  bool get isLoading => _isLoading;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get volumen => _volumen;
  String get filtroTexto => _filtroTexto;
  String get seccionActual => _seccionActual;
  List<Cancion> get colaReproduccion => _colaReproduccion;
  int get indiceCola => _indiceCola;
  String get modoReproduccion => _modoReproduccion;
  
  List<Cancion> get cancionesSiguientes {
    if (_modoReproduccion == 'queue' && _colaReproduccion.isNotEmpty) {
      if (_indiceCola + 1 < _colaReproduccion.length) {
        return _colaReproduccion.sublist(_indiceCola + 1);
      }
      return [];
    } else if (_cancionesFiltradas.isNotEmpty) {
      if (_indiceActual + 1 < _cancionesFiltradas.length) {
        return _cancionesFiltradas.sublist(_indiceActual + 1);
      }
      return [];
    }
    return [];
  }
  
  List<Cancion> get cancionesAnteriores {
    if (_modoReproduccion == 'queue' && _colaReproduccion.isNotEmpty) {
      if (_indiceCola > 0) {
        return _colaReproduccion.sublist(0, _indiceCola);
      }
      return [];
    } else if (_cancionesFiltradas.isNotEmpty) {
      if (_indiceActual > 0) {
        return _cancionesFiltradas.sublist(0, _indiceActual);
      }
      return [];
    }
    return [];
  }
  
  int get posicionActual {
    if (_modoReproduccion == 'queue' && _colaReproduccion.isNotEmpty) {
      return _indiceCola + 1;
    } else if (_cancionesFiltradas.isNotEmpty) {
      return _indiceActual + 1;
    }
    return 0;
  }
  
  int get totalCola {
    if (_modoReproduccion == 'queue') {
      return _colaReproduccion.length;
    }
    return _cancionesFiltradas.length;
  }

  AudioProvider() {
    _inicializarListener();
    cargarCanciones();
  }

  void _inicializarListener() {
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      if (_cancionActual != null) {
        _cancionActual!.duracionSegundos = duration.inSeconds;
        _cancionActual!.duracion = _formatearDuracion(duration);
        notifyListeners();
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) async {
      if (_isRepeat) {
        await _repetirCancionActual();
      } else if (_isShuffle) {
        await _reproducirSiguienteAleatorio();
      } else {
        await siguienteCancion();
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }

  String _formatearDuracion(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> cargarCanciones() async {
    _isLoading = true;
    notifyListeners();

    try {
      _canciones = await _supabaseService.obtenerCanciones();
      _cancionesFiltradas = List.from(_canciones);
      _cargarFavoritos();

      if (_cancionesFiltradas.isNotEmpty && _cancionActual == null) {
        _cancionActual = _cancionesFiltradas[0];
        _indiceActual = 0;
      }
    } catch (e) {
      _canciones = [];
      _cancionesFiltradas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _cargarFavoritos() {
    _cancionesFavoritas = _canciones.where((c) => c.esFavorita).toList();
  }

  void toggleFavorito(Cancion cancion) {
    cancion.esFavorita = !cancion.esFavorita;
    if (cancion.esFavorita) {
      _cancionesFavoritas.add(cancion);
    } else {
      _cancionesFavoritas.removeWhere((c) => c.id == cancion.id);
    }
    notifyListeners();
  }

  void crearCola(List<Cancion> canciones, {int startIndex = 0}) {
    _colaReproduccion = List.from(canciones);
    _indiceCola = startIndex;
    _modoReproduccion = 'queue';
    notifyListeners();
  }

  void anadirACola(Cancion cancion) {
    _colaReproduccion.add(cancion);
    notifyListeners();
  }

  void anadirMultiplesACola(List<Cancion> canciones) {
    _colaReproduccion.addAll(canciones);
    notifyListeners();
  }

  void eliminarDeCola(int index) {
    if (index >= 0 && index < _colaReproduccion.length) {
      _colaReproduccion.removeAt(index);
      if (index < _indiceCola) {
        _indiceCola--;
      }
      notifyListeners();
    }
  }

  void moverEnCola(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < _colaReproduccion.length &&
        newIndex >= 0 && newIndex < _colaReproduccion.length) {
      final cancion = _colaReproduccion.removeAt(oldIndex);
      _colaReproduccion.insert(newIndex, cancion);
      
      if (oldIndex == _indiceCola) {
        _indiceCola = newIndex;
      } else if (oldIndex < _indiceCola && newIndex >= _indiceCola) {
        _indiceCola--;
      } else if (oldIndex > _indiceCola && newIndex <= _indiceCola) {
        _indiceCola++;
      }
      notifyListeners();
    }
  }

  void limpiarCola() {
    _colaReproduccion.clear();
    _indiceCola = 0;
    _modoReproduccion = 'list';
    notifyListeners();
  }

  void cambiarModoLista() {
    _modoReproduccion = 'list';
    notifyListeners();
  }

  Future<void> reproducirDesdeCola(int index) async {
    if (index >= 0 && index < _colaReproduccion.length) {
      _indiceCola = index;
      _modoReproduccion = 'queue';
      await _reproducirCancion(_colaReproduccion[index]);
    }
  }

  Future<void> reproducirCancion(Cancion cancion) async {
    _indiceActual = _cancionesFiltradas.indexWhere((c) => c.id == cancion.id);
    
    if (_modoReproduccion == 'queue') {
      final indexEnCola = _colaReproduccion.indexWhere((c) => c.id == cancion.id);
      if (indexEnCola != -1) {
        _indiceCola = indexEnCola;
      } else {
        _modoReproduccion = 'list';
      }
    }
    
    notifyListeners();

    try {
      _cancionActual = cancion;
      await _audioPlayer.stop();
      await _audioPlayer.setSourceUrl(cancion.url);
      await _audioPlayer.setVolume(_volumen);
      await _audioPlayer.resume();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  void playPausa() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = false;
      } else {
        await _audioPlayer.resume();
        _isPlaying = true;
      }
      notifyListeners();
    } catch (e) {}
  }

  Future<void> siguienteCancion() async {
    if (_isShuffle) {
      await _reproducirSiguienteAleatorio();
      return;
    }

    if (_modoReproduccion == 'queue' && _colaReproduccion.isNotEmpty) {
      if (_indiceCola + 1 < _colaReproduccion.length) {
        _indiceCola++;
        await _reproducirCancion(_colaReproduccion[_indiceCola]);
      }
    } else {
      if (_cancionesFiltradas.isEmpty) return;
      
      if (_indiceActual + 1 < _cancionesFiltradas.length) {
        _indiceActual++;
        final nuevaCancion = _cancionesFiltradas[_indiceActual];
        await _reproducirCancion(nuevaCancion);
      }
    }
  }

  Future<void> cancionAnterior() async {
    if (_modoReproduccion == 'queue' && _colaReproduccion.isNotEmpty) {
      if (_indiceCola > 0) {
        _indiceCola--;
        await _reproducirCancion(_colaReproduccion[_indiceCola]);
      }
    } else {
      if (_cancionesFiltradas.isEmpty) return;
      
      if (_indiceActual > 0) {
        _indiceActual--;
        final nuevaCancion = _cancionesFiltradas[_indiceActual];
        await _reproducirCancion(nuevaCancion);
      }
    }
  }

  Future<void> _reproducirSiguienteAleatorio() async {
    if (_modoReproduccion == 'queue' && _colaReproduccion.isNotEmpty) {
      if (_colaReproduccion.length <= 1) return;
      
      int nuevoIndice = _indiceCola;
      while (nuevoIndice == _indiceCola) {
        nuevoIndice = DateTime.now().millisecondsSinceEpoch % _colaReproduccion.length;
      }
      _indiceCola = nuevoIndice;
      await _reproducirCancion(_colaReproduccion[_indiceCola]);
    } else {
      if (_cancionesFiltradas.length <= 1) return;
      
      int nuevoIndice = _indiceActual;
      while (nuevoIndice == _indiceActual) {
        nuevoIndice = DateTime.now().millisecondsSinceEpoch % _cancionesFiltradas.length;
      }
      _indiceActual = nuevoIndice;
      await _reproducirCancion(_cancionesFiltradas[_indiceActual]);
    }
  }

  Future<void> _repetirCancionActual() async {
    if (_cancionActual == null) return;
    
    await _audioPlayer.seek(Duration.zero);
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> _reproducirCancion(Cancion cancion) async {
    try {
      _cancionActual = cancion;
      await _audioPlayer.stop();
      await _audioPlayer.setSourceUrl(cancion.url);
      await _audioPlayer.setVolume(_volumen);
      await _audioPlayer.resume();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {}
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_isShuffle) {
      _isRepeat = false;
    }
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    if (_isRepeat) {
      _isShuffle = false;
    }
    notifyListeners();
  }

  void seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void cambiarVolumen(double volumen) {
    _volumen = volumen.clamp(0.0, 1.0);
    _audioPlayer.setVolume(_volumen);
    notifyListeners();
  }

  void filtrarCanciones(String texto) {
    _filtroTexto = texto;
    if (_filtroTexto.isEmpty) {
      _cancionesFiltradas = List.from(_canciones);
    } else {
      _cancionesFiltradas = _canciones.where((cancion) {
        return cancion.titulo.toLowerCase().contains(_filtroTexto.toLowerCase()) ||
               cancion.artista.toLowerCase().contains(_filtroTexto.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void limpiarFiltro() {
    _filtroTexto = '';
    _cancionesFiltradas = List.from(_canciones);
    notifyListeners();
  }

  void cambiarSeccion(String seccion) {
    _seccionActual = seccion;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}