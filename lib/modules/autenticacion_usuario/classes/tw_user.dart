
import 'package:cloud_firestore/cloud_firestore.dart';

class TWUser {
  final String username;
  final String type;
  final Uri? pfp;
  final String email;
  final Timestamp createdAt;

  TWUser({required this.username, required this.type, required this.email, required this.createdAt, this.pfp});

  factory TWUser.fromJson(Map<String,dynamic> json){
    return TWUser(
      username: json['username'],
      type: json['type'],
      email: json['email'],
      createdAt: json['created_at'],
      pfp: json['pfp']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'username': username,
      'type': type,
      'email': email,
      'created_at': createdAt,
      'pfp': pfp
    };
  }

}