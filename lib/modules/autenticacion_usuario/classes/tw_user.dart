
import 'package:cloud_firestore/cloud_firestore.dart';

class TWUser {
  final String username;
  final String type;
  final Uri? pfp;
  final String email;
  Timestamp? createdAt;

  TWUser({required this.username, required this.type, Timestamp? createdAt, required this.email, this.pfp}){
    this.createdAt = createdAt ?? Timestamp.now();
  }

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

  @override
  String toString() {
    return """
      username: $username
      type: $type
      email: $email
      create_at ${createdAt.toString()}
      pfp ${pfp ?? "no pfp"}
    """;
  }

}