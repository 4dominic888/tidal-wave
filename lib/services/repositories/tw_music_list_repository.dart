import 'package:tidal_wave/modules/home_page/classes/music_list.dart';
import 'package:tidal_wave/services/repositories/repository_base.dart';
import 'package:tidal_wave/shared/result.dart';

class TWMusicListRepository extends RepositoryBase<MusicList>{

  @override
  String get collectionName => 'User-List-Musics';

  @override
  Future<Result<MusicList>> addOne(MusicList data, String? id, [List<String> queryArray = const []]) {
    // TODO: implement addOne
    throw UnimplementedError();
  }

  @override
  Future<Result<MusicList>> getOne(String id, [List<String> queryArray = const []]) {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Future<Result<List<MusicList>>> getAll([List<String> queryArray = const [], bool Function(Map<String, dynamic> p1)? where, int limit = 10]) {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Result> deleteOne(String id, [List<String> queryArray = const []]) {
    // TODO: implement deleteOne
    throw UnimplementedError();
  }



  @override
  Future<Result<MusicList>> updateOne(MusicList data, String id, [List<String> queryArray = const []]) {
    // TODO: implement updateOne
    throw UnimplementedError();
  }
  
}