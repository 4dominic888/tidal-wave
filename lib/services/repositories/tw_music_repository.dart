import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';
import 'package:tidal_wave/services/repositories/repository_base.dart';
import 'package:tidal_wave/shared/result.dart';

class TWMusicRepository extends RepositoryBase<Music> {
  
  @override
  String get collectionName => 'Musics';

  @override
  Future<Result<Music>> addOne(Music data, String? id, [List<String> queryArray = const []]) async{
    try {
      if(id == null){
        await context.addOne(collectionName, data.toJson(), queryArray);
      } else{
        await context.setOne(collectionName, data.toJson(), id, queryArray);
      }
      return Result.sucess(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }    
  }

  @override
  Future<Result<List<Music>>> getAll({List<String> queryArray = const [], bool Function(Map<String, dynamic> query)? where, int limit = 10}) async {
    try {
      int index = -1;
      final data = await context.getAll(collectionName, queryArray, where, limit);
      return Result.sucess(data.map((e) {
        index++;
        return Music.fromJson(e,index);
      } ).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  Future<Result<List<Music>>> getAllByReferences(List<String> references, {bool Function(Map<String, dynamic> query)? where, int limit = 10}) async {
    try {
      int index = -1;
      final data = await context.getAllByReferences(references);
      return Result.sucess(data.map((e) {
        index++;
        return Music.fromJson(e,index);
      } ).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result> deleteOne(String id, [List<String> queryArray = const []]) {
    // TODO: implement deleteOne
    throw UnimplementedError();
  }


  @override
  Future<Result<Music>> getOne(String id, [List<String> queryArray = const []]) {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Future<Result<Music>> updateOne(Music data, String id, [List<String> queryArray = const []]) {
    // TODO: implement updateOne
    throw UnimplementedError();
  }
  
}