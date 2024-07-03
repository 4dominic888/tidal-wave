import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/domain/models/music.dart';

class MusicList {
  final String id;
  final String name;
  final String description;
  final Uri? image;
  final DataSourceType? type;
  //? UID de las musicas
  final List<Music>? musics;

  MusicList({required this.id, required this.name, required this.description, this.type, this.musics, this.image});

  MusicList.toSend({required this.name, required this.description, this.type, this.image}): id = '', musics=[];

  factory MusicList.fromJson(Map<String,dynamic> json) => MusicList(
    id: json['uuid'],
    name: json['name'],
    description: json['description'],
    type: getDataSourceTypeByString(json['type']),
    image: json['image'] != null ? Uri.parse(json['image']) : null
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> musicListJson = {
      'name': name,
      'type': type.toString(),
      'description': description,
      'image': image.toString()
    };
    return musicListJson;
  }

  MusicList copyWith({String? id, String? name, String? description, Uri? image, DataSourceType? type, List<Music>? musics}){
    return MusicList(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      image: image ?? this.image,
      musics: musics ?? this.musics
    );
  }
}