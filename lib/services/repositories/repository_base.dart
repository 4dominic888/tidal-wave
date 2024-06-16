import 'package:tidal_wave/data/dataSources/firebase/firebase_database_service.dart';
import 'package:tidal_wave/data/result.dart';

abstract class RepositoryBase<T> {

  FireBaseDatabaseService get context => FireBaseDatabaseService();
  String get collectionName;

  Future<Result<List<T>>> getAll({List<String> queryArray = const [], bool Function(Map<String, dynamic>)? where, int limit});
  Future<Result<T>> getOne(String id, [List<String> queryArray = const []]);
  Future<Result<T>> addOne(T data, String? id, [List<String> queryArray = const []]);
  Future<Result<T>> updateOne(T data, String id, [List<String> queryArray = const []]);
  Future<Result<dynamic>> deleteOne(String id, [List<String> queryArray = const []]);
}