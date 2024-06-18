import 'package:tidal_wave/domain/models/tw_user.dart';
import 'package:tidal_wave/data/repositories/repository_implement_base.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/repositories/user_repository.dart';

typedef T = TWUser;

class UserRepositoryImplement extends RepositoryImplementBase<T> with OnlyFirestoreAction<T> implements UserRepository{
  UserRepositoryImplement(super.type);

  @override
  String get dataset => 'Users';

  @override
  Future<Result<List<T>>> getAll({List<String> queryArray = const [], bool Function(Map<String, dynamic>)? where, int limit = 10}) async{
    try {
      late final List<Map<String, dynamic>> data;
      actionOnlyFirestore((firestoreContext) async => data = await firestoreContext.getAll(dataset, queryArray, where, limit));
      return Result.sucess(data.map((e) => T.fromJson(e)).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
  
  @override
  Future<Result<T>> getOne(String id, [List<String> queryArray = const []]) async {
    try {
      late final Map<String, dynamic>? data;
      actionOnlyFirestore((firestoreContext) async => data = await firestoreContext.getOne(dataset, id, queryArray));

      if (data == null) {
        return Result.error('No se ha encontrado el elemento');
      }
      return Result.sucess(T.fromJson(data!));
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<T>> addOne(T data, String? id, [List<String> queryArray = const []]) async {
    try {
      actionOnlyFirestore((firestoreContext) async {
        if(id == null){
          await firestoreContext.addOne(dataset, data.toJson(), queryArray);
        } else{
          await firestoreContext.setOne(dataset, data.toJson(), id, queryArray);
        }
      });
      return Result.sucess(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
    
  @override
  Future<Result<T>> updateOne(T data, String id, [List<String> queryArray = const []]) async {
    try {
      late final Map<String, dynamic> retorno;
      actionOnlyFirestore((firestoreContext) async => retorno = await firestoreContext.updateOne(dataset, data.toJson(), id, queryArray));
      return Result.sucess(T.fromJson(retorno));
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
  
  @override
  Future<Result<String>> deleteOne(String id, [List<String> queryArray = const []]) async {
    try {
      actionOnlyFirestore((firestoreContext) async => await firestoreContext.deleteOne(dataset, id, queryArray));
      return Result.sucess(id);
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