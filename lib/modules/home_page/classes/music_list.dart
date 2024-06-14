import 'package:cloud_firestore/cloud_firestore.dart';

class MusicList {
  final String id;
  final String name;
  final String description;
  final Uri? image;
  final String type;
  final List<DocumentReference<Map<String, dynamic>>> musics;

  MusicList({required this.id, required this.name, required this.description, required this.type, required this.musics, this.image});

  factory MusicList.fromJson(Map<String,dynamic> json, String uuid, String type) => MusicList(
    id: uuid,
    name: json['name'],
    description: json['description'],
    type: type,
    //* TODA ESTA LINEA LARGOTA PARA RECUPERAR UNA SIMPLE LISTA DE REFERENCIAS, ESTUVE 4 DIAS SIN SABER COMO AAAAAAAAAAAAAA
    musics: (json['musics'] as List).map<DocumentReference<Map<String, dynamic>>>((e) => FirebaseFirestore.instance.doc((e as DocumentReference).path)).toList()
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'musics': musics
  };
}