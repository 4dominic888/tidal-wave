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
  Future<Result<List<MusicList>>> getAll({List<String> queryArray = const [], bool Function(Map<String, dynamic> p1)? where, int limit = 10}) async {
    // TODO: implement addOne
    throw UnimplementedError();
  }

  Future<Result<List<MusicList>>> getUserListByType(String userId, String type, [bool Function(Map<String, dynamic> p1)? where, int limit = 10]) async {
    try {
      final data = await context.getAll(collectionName, [userId, type], where, limit);
      if(data.isEmpty) return Result.sucess([]);
      return Result.sucess(data.map((e) => MusicList.fromJson(e, userId, type)).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  Future<Result<List<MusicList>>> getAllListForUser(String userId, [bool Function(Map<String, dynamic> p1)? where, int limit = 10]) async {
    try {
      final publicList = await getUserListByType(userId, 'public-list');
      final privateList = await getUserListByType(userId, 'private-list');
      //TODO: local list implement
      return Result.sucess([...publicList.data!, ...privateList.data!]);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }



  Future<Result<List<MusicList>>> getLocalList({List<String> queryArray = const [], bool Function(Map<String, dynamic> p1)? where, int limit = 10}) async {
    // TODO: implement getLocalLIst
    throw UnimplementedError();
  }

  @override
  Future<Result<MusicList>> getOne(String id, [List<String> queryArray = const []]) {
    // TODO: implement getOne
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