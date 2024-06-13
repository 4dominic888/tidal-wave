import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';

class MusicList {
  final String id;
  final String name;
  final String description;
  final Uri? image;
  final String type;
  final List<Music> musics;

  MusicList({required this.id, required this.name, required this.description, required this.type, required this.musics, this.image});
}