import 'package:tidal_wave/services/firebase_database_service.dart';
import 'package:tidal_wave/shared/result.dart';

abstract class RepositoryBase<T> {

  FireBaseDatabaseService get context => FireBaseDatabaseService();
  String get collectionName;

  Future<Result<List<T>>> getAll([bool Function(Map<String, dynamic>)? where, int limit]);
  Future<Result<T>> setOne(T data, String id);
  Future<Result<T>> getOne(String id);
  Future<Result<T>> addOne(T data);
  Future<Result<T>> updateOne(T data, String id);
  Future<Result<dynamic>> deleteOne(String id);
}