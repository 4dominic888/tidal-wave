import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/repositories/crud_interfaces.dart';

typedef T = Music;

abstract class MusicRepository implements Addable<T>, GetOneable<T>, GetAllable<T>, Updatable<T>, Deletable{
  
  @override
  Future<Result<T>> addOne(T data, String? id);

  @override
  Future<Result<T>> getOne(String id);

  @override
  Future<Result<List<T>>> getAll({bool Function(Map<String, dynamic> query)? where, int limit = 10});

  @override
  Future<Result<T>> updateOne(T data, String id);

  @override
  Future<Result<String>> deleteOne(String id);

  /// Only firebase
  Future<Result<List<T>>> getAllByReferences(List<DocumentReference<Map<String, dynamic>>> references);
}