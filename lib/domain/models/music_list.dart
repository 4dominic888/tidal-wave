import 'package:cloud_firestore/cloud_firestore.dart';

class MusicList {
  final String id;
  final String name;
  final String description;
  final Uri? image;
  final String type;
  final List<DocumentReference<Map<String, dynamic>>> musics;

  MusicList({required this.id, required this.name, required this.description, required this.type, required this.musics, this.image});

  MusicList.toSend({required this.name, required this.description, required this.type, this.image}): id = '', musics=[];

  factory MusicList.fromJson(Map<String,dynamic> json, String type) => MusicList(
    id: json['uuid'],
    name: json['name'],
    description: json['description'],
    type: type,
    //* TODA ESTA LINEA LARGOTA PARA RECUPERAR UNA SIMPLE LISTA DE REFERENCIAS, ESTUVE 4 DIAS SIN SABER COMO AAAAAAAAAAAAAA
    musics: (json['musics'] as List).map<DocumentReference<Map<String, dynamic>>>((e) => FirebaseFirestore.instance.doc((e as DocumentReference).path)).toList(),
    image: Uri.parse(json['image'])
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'musics': musics,
    'image': image.toString()
  };
}