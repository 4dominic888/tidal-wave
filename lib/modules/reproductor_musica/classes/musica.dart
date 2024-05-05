import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class Music {
  String titulo;
  String artista;
  Uri? imagen;
  Uri musica;
  bool? favorito = false;
  Duration duration;

  Music({
    required this.titulo,
    required this.artista,
    required this.musica,
    required this.duration,
    this.imagen,
    this.favorito,
  });

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