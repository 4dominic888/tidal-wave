import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/shared/utils.dart';

class Music {
  final String? uuid;
  final int _index;
  final String titulo;
  final List<String> artistas;
  final Uri? imagen;
  final Uri musica;
  final Duration duration;
  final double stars;
  final DocumentReference uploadBy;
  final Timestamp uploadAt;
  final Duration betterMoment;
  bool? favorito = false;

  Music.byUID(int? index,{
    required this.titulo,
    required this.artistas,
    required this.musica,
    required this.duration,
    required this.stars,
    required this.uploadAt,
    required String userId,
    required this.betterMoment,
    this.uuid,
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
    required this.betterMoment,
    this.uuid,
    this.imagen,
    this.favorito,
  }) : _index = index ?? -1;  

  factory Music.fromJson(Map<String,dynamic> json, int? index){
    return Music(index ?? -1,
      uuid: json['uuid'],
      titulo: json['title'],
      artistas: json['artist'] is Iterable ? List.from(json['artist']) : [],
      musica: Uri.parse(json['musicUri'] as String),
      imagen: Uri.parse(json['artUri']),
      duration: Duration(milliseconds: json['duration'] as int),
      stars: json['stars'] as double,
      uploadAt: json['upload_at'],
      uploadBy: FirebaseFirestore.instance.doc((json['upload_by'] as DocumentReference).path),
      betterMoment: Duration(milliseconds: json['better_moment'] as int)
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

  String get durationString => toStringDurationFormat(duration);
  String get betterMomentString => toStringDurationFormat(betterMoment);
  Future<String> get uploadAtName async {
    final user = await uploadBy.get();
    return (user.data() as Map<String, dynamic>)['username'];
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
      "upload_by": uploadBy,
      "better_moment": betterMoment.inMilliseconds
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