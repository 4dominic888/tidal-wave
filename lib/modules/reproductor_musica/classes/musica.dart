import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class Music {
  final int _index;
  final String titulo;
  final List<String> artistas;
  final Uri? imagen;
  final Uri musica;
  final Duration duration;
  final double stars;
  final DocumentReference? uploadBy;
  final Timestamp uploadAt;
  bool? favorito = false;

  Music.byUID(int? index,{
    required this.titulo,
    required this.artistas,
    required this.musica,
    required this.duration,
    required this.stars,
    required this.uploadAt,
    required String userId,
    this.imagen,
    this.favorito,
  }) : _index = index ?? -1, uploadBy = FirebaseFirestore.instance.collection('Users').doc(userId);

  Music(int? index,{
    required this.titulo,
    required this.artistas,
    required this.musica,
    required this.duration,
    required this.stars,
    required this.uploadAt,
    required this.uploadBy,
    this.imagen,
    this.favorito,
  }) : _index = index ?? -1;  

  factory Music.fromJson(Map<String,dynamic> json, int? index){

    print(json);
    
    return Music(index ?? -1,
      titulo: json['title'],
      artistas: json['artist'] is Iterable ? List.from(json['artist']) : [],
      musica: Uri.parse(json['musicUri'] as String),
      imagen: Uri.parse(json['artUri']),
      duration: Duration(milliseconds: json['duration'] as int),
      stars: json['stars'] as double,
      uploadAt: json['upload_at'],
      uploadBy: json['upload_by'] is DocumentReference ? json['upload_by'] as DocumentReference : null
    );
  }

  int get index => _index;

  String get artistasStr {
    StringBuffer retorno = StringBuffer();

    if(artistas.length == 1) return artistas.first;

    for (int i = 0; i < artistas.length; i++) {
      retorno.write(artistas[i]);
      if (i < artistas.length - 1) {
        retorno.write(', ');
      } else {
        retorno.write(' & ');
      }
    }

    return retorno.toString();
  }

  String get durationString {
    String formattedDuration = '';
    if (duration.inHours > 0) {
      formattedDuration += '${duration.inHours}:';
    }
    formattedDuration += '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:';
    formattedDuration += duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return formattedDuration;
  }

  Map<String,dynamic> toJson(){
    return {
      "title": titulo,
      "artist": artistas,
      "musicUri": musica.toString(),
      "artUri": imagen.toString(),
      "duration": duration.inMilliseconds,
      "stars": stars,
      "upload_at": uploadAt,
      "upload_by": uploadBy
    };
  }

  AudioSource toAudioSource(String index){
    return AudioSource.uri(musica,
    tag: MediaItem(
      id: index,
      title: titulo,
      artist: artistasStr,
      artUri: imagen
    ));
  }
}