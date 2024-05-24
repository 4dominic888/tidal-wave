import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class Music {
  final int _index;
  final String titulo;
  final String artista;
  final Uri? imagen;
  final Uri musica;
  final Duration duration;
  bool? favorito = false;

  Music(int? index,{
    required this.titulo,
    required this.artista,
    required this.musica,
    required this.duration,
    this.imagen,
    this.favorito,
  }) : _index = index ?? -1;

  int get index => _index;

  String get durationString {
    String formattedDuration = '';
    if (duration.inHours > 0) {
      formattedDuration += '${duration.inHours}:';
    }
    formattedDuration += '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:';
    formattedDuration += duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return formattedDuration;
  }

  AudioSource toAudioSource(String index){
    return AudioSource.uri(musica,
    tag: MediaItem(
      id: index,
      title: titulo,
      artist: artista,
      artUri: imagen
    ));
  }
}