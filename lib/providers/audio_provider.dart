import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/cancion.dart';
import '../services/supabase_service.dart';

class AudioProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Cancion> _canciones = [];
  List<Cancion> _cancionesFiltradas = [];
  List<Cancion> _cancionesFavoritas = [];
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

  AudioProvider() {
    _inicializarListener();
    cargarCanciones();
  }

  void _inicializarListener() {
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        if (_cancionActual != null) {
          _cancionActual!.duracionSegundos = duration.inSeconds;
          _cancionActual!.duracion = _formatearDuracion(duration);
          notifyListeners();
        }
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
      
      if (state.processingState == ProcessingState.completed) {
        if (_isRepeat) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else if (_isShuffle) {
          _reproducirSiguienteAleatorio();
        } else {
          siguienteCancion();
        }
      }
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
      _aplicarFiltro();
      _cargarFavoritos();
      
      if (_cancionesFiltradas.isNotEmpty && _cancionActual == null) {
        _cancionActual = _cancionesFiltradas[0];
        _indiceActual = 0;
      }
      
      debugPrint('Canciones cargadas: ${_canciones.length}');
    } catch (e) {
      debugPrint('Error cargando canciones: $e');
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

  Future<void> reproducirCancion(Cancion cancion) async {
    debugPrint('Reproduciendo: ${cancion.titulo}');
    
    _indiceActual = _cancionesFiltradas.indexWhere((c) => c.id == cancion.id);
    notifyListeners();
    
    try {
      _cancionActual = cancion;
      await _audioPlayer.setUrl(cancion.url);
      await _audioPlayer.setVolume(_volumen);
      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error reproduciendo: $e');
      notifyListeners();
    }
  }

  void playPausa() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      _isPlaying = !_isPlaying;
      notifyListeners();
    } catch (e) {
      debugPrint('Error en play/pausa: $e');
    }
  }

  void siguienteCancion() {
    if (_cancionesFiltradas.isEmpty) return;
    
    if (_indiceActual + 1 < _cancionesFiltradas.length) {
      _indiceActual++;
      _reproducirCancion(_cancionesFiltradas[_indiceActual]);
    }
  }

  void cancionAnterior() {
    if (_cancionesFiltradas.isEmpty) return;
    
    if (_indiceActual > 0) {
      _indiceActual--;
      _reproducirCancion(_cancionesFiltradas[_indiceActual]);
    }
  }

  void _reproducirSiguienteAleatorio() {
    if (_cancionesFiltradas.length <= 1) return;
    
    int nuevoIndice = _indiceActual;
    while (nuevoIndice == _indiceActual) {
      nuevoIndice = DateTime.now().millisecondsSinceEpoch % _cancionesFiltradas.length;
    }
    
    _indiceActual = nuevoIndice;
    _reproducirCancion(_cancionesFiltradas[_indiceActual]);
  }

  Future<void> _reproducirCancion(Cancion cancion) async {
    try {
      _cancionActual = cancion;
      await _audioPlayer.setUrl(cancion.url);
      await _audioPlayer.setVolume(_volumen);
      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error reproduciendo: $e');
      notifyListeners();
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    notifyListeners();
  }

  void seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void cambiarVolumen(double volumen) {
    _volumen = volumen;
    _audioPlayer.setVolume(_volumen);
    notifyListeners();
  }

  void filtrarCanciones(String texto) {
    _filtroTexto = texto;
    _aplicarFiltro();
    notifyListeners();
  }

  void _aplicarFiltro() {
    if (_filtroTexto.isEmpty) {
      _cancionesFiltradas = List.from(_canciones);
    } else {
      _cancionesFiltradas = _canciones.where((cancion) {
        return cancion.titulo.toLowerCase().contains(_filtroTexto.toLowerCase()) ||
               cancion.artista.toLowerCase().contains(_filtroTexto.toLowerCase());
      }).toList();
    }
  }

  void limpiarFiltro() {
    _filtroTexto = '';
    _aplicarFiltro();
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