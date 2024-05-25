import 'package:tidal_wave/modules/autenticacion_usuario/classes/tw_user.dart';
import 'package:tidal_wave/services/repositories/repository_base.dart';
import 'package:tidal_wave/shared/result.dart';

class TWUserRepository extends RepositoryBase<TWUser> {
  @override
  String get collectionName => 'Users';

  @override
  Future<Result<List<TWUser>>> getAll([bool Function(Map<String, dynamic>)? where, int limit = 10]) async{
    try {
      final data = await context.getAll(collectionName, where, limit);
      return Result.sucess(data.map((e) => TWUser.fromJson(e)).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
  
  @override
  Future<Result<TWUser>> getOne(String id) async {
    try {
      final data = await context.getOne(collectionName, id);
      if (data == null) {
        return Result.error('No se ha encontrado el elemento');
      }
      return Result.sucess(TWUser.fromJson(data));
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<TWUser>> addOne(TWUser data, String? id) async {
    try {
      if(id == null){
        await context.addOne(collectionName, data.toJson());
      } else{
        await context.setOne(collectionName, data.toJson(), id);
      }
      return Result.sucess(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
    
  @override
  Future<Result<TWUser>> updateOne(TWUser data, String id) async {
    try {
      final retorno = await context.updateOne(collectionName, data.toJson(), id);
      return Result.sucess(TWUser.fromJson(retorno));
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
  
  @override
  Future<Result<String>> deleteOne(String id) async{
    try {
      await context.deleteOne(collectionName, id);
      return Result.sucess(id);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
}