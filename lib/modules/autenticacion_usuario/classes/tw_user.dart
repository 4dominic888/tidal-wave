
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
      pfp: Uri.parse(json['pfp'])
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'username': username,
      'type': type,
      'email': email,
      'created_at': createdAt,
      'pfp': pfp.toString()
    };
  }

  String get readCreatedAt => createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt!.toDate()) : 'unknown';

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

  TWUser copyWith({String? username, String? type, Uri? pfp, String? email}) { 
    return TWUser(
      username: username ?? this.username,
      type: type ?? this.type,
      pfp: pfp ?? this.pfp,
      email: email ?? this.email
    );
  }

}