import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class Music {
  String titulo;
  String artista;
  Uri? imagen;
  Uri musica;
  bool? favorito = false;

  Music({
    required this.titulo,
    required this.artista,
    required this.musica,
    this.imagen,
    this.favorito
  });

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