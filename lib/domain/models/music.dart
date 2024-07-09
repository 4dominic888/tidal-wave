import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/presentation/utils/function_utils.dart';

class Music {
  final String? uuid;
  int _index;
  final String titulo;
  final List<String> artistas;
  final Uri? imagen;
  final Uri musica;
  final Duration duration;
  final double? stars;
  final Timestamp uploadAt;
  final Duration betterMoment;
  final DataSourceType type;
  bool favorito = false;

  Music({
    int? index,
    required this.titulo,
    required this.artistas,
    required this.musica,
    required this.duration,
    required this.uploadAt,
    required this.betterMoment,
    required this.type,
    this.stars,
    this.uuid,
    this.imagen,
    this.favorito = false,
  }) : _index = index ?? -1;  

  factory Music.fromJson(Map<String,dynamic> json, int? index){
    return Music(
      index: index ?? -1,
      uuid: json['uuid'],
      titulo: json['title'],
      artistas: (jsonDecode(json['artist']) is List) ? List.from(jsonDecode(json['artist'])) : [],
      musica: Uri.parse(json['musicUri'] as String),
      imagen: Uri.parse(json['artUri']),
      duration: Duration(milliseconds: json['duration'] as int),
      type: getDataSourceTypeByString(json['type']),
      stars: json['stars'] as double,
      uploadAt: Timestamp.fromMillisecondsSinceEpoch(json['upload_at'] as int),
      betterMoment: Duration(milliseconds: json['better_moment'] as int)
    );
  }

  factory Music.fromJsonLocal(Map<String, dynamic> json, int? index){
    return Music.fromJson(json, index).copyWith(favorito: json['favorite'] as int == 1);
  }

  int get index => _index;
  set index(int index) => _index = index;

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


  Map<String,dynamic> toJson(){
    return {
      "title": titulo,
      "artist": jsonEncode(artistas),
      "musicUri": musica.toString(),
      "artUri": imagen.toString(),
      "duration": duration.inMilliseconds,
      "type": type.toString(),
      "stars": stars,
      "upload_at": uploadAt.millisecondsSinceEpoch,
      "better_moment": betterMoment.inMilliseconds
    };
  }

  Map<String, dynamic> toJsonLocal(){
    return toJson()..addAll({'favorite': favorito ? 1 : 0});
  }

  AudioSource toAudioSource(String index){
    final tag = MediaItem(
      id: index,
      title: titulo,
      artist: artistasStr,
      artUri: imagen ?? Uri.parse('package:flutter_app/assets/placeholder/music-placeholder.png')
    );

    if(type == DataSourceType.online){
      return AudioSource.uri(musica, tag: tag);
    }
    return AudioSource.file(File(musica.toString()).path, tag: tag);

  }

  Music copyWith({
    int? index,
    String? uuid,
    String? titulo,
    List<String>? artistas,
    Uri? imagen,
    Uri? musica,
    Duration? duration,
    double? stars,
    Timestamp? uploadAt,
    Duration? betterMoment,
    DataSourceType? type,
    bool? favorito
  }){
    return Music(
      index: index ?? this.index,
      uuid: uuid ?? this.uuid,
      titulo: titulo ?? this.titulo,
      artistas: artistas ?? this.artistas,
      imagen: imagen ?? this.imagen,
      musica: musica ?? this.musica,
      duration: duration ?? this.duration,
      stars: stars ?? this.stars,
      uploadAt: uploadAt ?? this.uploadAt,
      betterMoment: betterMoment ?? this.betterMoment,
      type: type ?? this.type
    );
  }
}