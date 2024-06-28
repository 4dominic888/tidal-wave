import 'package:tidal_wave/domain/models/tw_user.dart';
import 'package:tidal_wave/data/abstractions/repository_implement_base.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/repositories/user_repository.dart';

typedef T = TWUser;

class UserRepositoryImplement extends RepositoryImplementBase with UseFirestore implements UserRepository{
  UserRepositoryImplement({required super.onlineContext, required super.offlineContext});

  @override
  String get dataset => 'Users';

  @override
  Future<Result<List<T>>> getAll({List<String> queryArray = const [], bool Function(Map<String, dynamic>)? where, int? timestamp, int limit = 10}) async{
    try {
      final data = await onlinefirestoreContext.getAll(dataset, queryArray, where, timestamp, limit);
      return Result.success(data.map((e) => T.fromJson(e)).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
  
  @override
  Future<Result<T>> getOne(String id, [List<String> queryArray = const []]) async {
    try {
      final data = await onlinefirestoreContext.getOne(dataset, id, queryArray);
      if (data == null) {
        return Result.error('No se ha encontrado el elemento');
      }
      return Result.success(T.fromJson(data));
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<T>> addOne(T data, [String? id, List<String> queryArray = const []]) async {
    try {
      if(id == null){
        await onlinefirestoreContext.addOne(dataset, data.toJson(), queryArray);
      } else{
        await onlinefirestoreContext.setOne(dataset, data.toJson(), id, queryArray);
      }
      return Result.success(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
    
  @override
  Future<Result<bool>> updateOne(T data, String id, [List<String> queryArray = const []]) async {
    try {
      await onlinefirestoreContext.updateOne(dataset, data.toJson(), id, queryArray);
      return Result.success(true);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
  
  @override
  Future<Result<String>> deleteOne(String id, [List<String> queryArray = const []]) async {
    try {
      onlinefirestoreContext.deleteOne(dataset, id, queryArray);
      return Result.success(id);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<T>> getLocalUser() {
    // TODO: implement getLocalUser
    throw UnimplementedError();
  }
}