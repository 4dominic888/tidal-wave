import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';
import 'package:tidal_wave/services/repositories/repository_base.dart';
import 'package:tidal_wave/shared/result.dart';

class TWMusicRepository extends RepositoryBase<Music> {
  
  @override
  String get collectionName => 'Musics';

  @override
  Future<Result<Music>> addOne(Music data, String? id) async{
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
  Future<Result> deleteOne(String id) {
    // TODO: implement deleteOne
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Music>>> getAll([bool Function(Map<String, dynamic> p1)? where, int limit = 10]) {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Result<Music>> getOne(String id) {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Future<Result<Music>> updateOne(Music data, String id) {
    // TODO: implement updateOne
    throw UnimplementedError();
  }
  
}