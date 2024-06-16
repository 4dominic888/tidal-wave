import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/services/repositories/repository_base.dart';
import 'package:tidal_wave/shared/result.dart';

class TWMusicListRepository extends RepositoryBase<MusicList>{

  @override
  String get collectionName => 'User-List-Musics';

  @override
  Future<Result<MusicList>> addOne(MusicList data, String? id, [List<String> queryArray = const []]) async {
    try {
      if(id == null){
        await context.addOne(collectionName, data.toJson(), [FirebaseAuth.instance.currentUser!.uid, data.type]);
      }
      else{
        await context.setOne(collectionName, data.toJson(), id, [FirebaseAuth.instance.currentUser!.uid, data.type]);
      }
      return Result.sucess(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
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
      return Result.sucess(data.map((e) => MusicList.fromJson(e, e['uuid'], type)).toList());
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

  Future<Result<String>> addMusic({required String musicUUID, required String userId, required String listId, required String listType}) async {
    try {
      DocumentReference<Map<String,dynamic>> musicReference = context.db.collection('Musics').doc(musicUUID);
      final listResult = await getOne(listId, [userId, listType]);
      if(!listResult.onSuccess) throw Exception(listResult.errorMessage!);
      listResult.data!.musics.add(musicReference);
      context.updateOne(collectionName, listResult.data!.toJson(), listId, [userId, listType]);
      return Result.sucess('Se ha agragado la musica con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<MusicList>> getOne(String id, [List<String> queryArray = const []]) async {
    try {
      final data = await context.getOne(collectionName, id, queryArray);
      return data != null ? Result.sucess(MusicList.fromJson(data, queryArray[0], queryArray[1]) ) : Result.error('No se ha encontrado el elemento');
    } catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result> deleteOne(String id, [List<String> queryArray = const []]) {
    // TODO: implement deleteOne
    throw UnimplementedError();
  }

  @override
  Future<Result<MusicList>> updateOne(MusicList data, String id, [List<String> queryArray = const []]) async {
    try {
      final retorno = await context.updateOne(collectionName, data.toJson(), id, queryArray);
      return Result.sucess(MusicList.fromJson(retorno, queryArray[0], queryArray[1]));
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }
  
}