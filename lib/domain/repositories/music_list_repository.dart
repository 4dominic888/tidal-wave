import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/repositories/interfaces_crud.dart';

typedef T = MusicList;

abstract class MusicListRepository implements Addable<T>, GetOneable<T>, Updatable<T>, Deletable{
  
  @override
  Future<Result<T>> addOne(MusicList data, String? id);

  @override
  Future<Result<T>> getOne(String id);

  @override
  Future<Result<String>> deleteOne(String id);

  @override
  Future<Result<T>> updateOne(MusicList data, String id);

  Future<Result<List<T>>> getUserListByType(String userId, String type);
  Future<Result<List<T>>> getAllListForUser(String userId);
  Future<Result<String>> addMusic({required String musicUUID, required String userId, required String listId, required String listType});
}