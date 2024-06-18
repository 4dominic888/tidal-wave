import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/data/repositories/repository_implement_base.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/repositories/music_list_repository.dart';

class MusicListRepositoryImplement extends RepositoryImplementBase with UseFirestore implements MusicListRepository{
  
  MusicListRepositoryImplement() : super.firestore();

  @override
  String get dataset => 'User-List-Musics';

  @override
  Future<Result<T>> addOne(MusicList data, String? id, [List<String> queryArray = const []]) async {
    try {
      if(id == null){
        await firestoreContext.addOne(dataset, data.toJson(), [FirebaseAuth.instance.currentUser!.uid, data.type]);
      }
      else{
        await firestoreContext.setOne(dataset, data.toJson(), id, [FirebaseAuth.instance.currentUser!.uid, data.type]);
      }
      return Result.sucess(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<List<T>>> getUserListByType(String userId, String type, [bool Function(Map<String, dynamic> p1)? where, int limit = 10]) async {
    try {
      final data = await firestoreContext.getAll(dataset, [userId, type], where, limit);
      return Result.sucess(data.map((e) => T.fromJson(e, type)).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<List<T>>> getAllListForUser(String userId, [bool Function(Map<String, dynamic> p1)? where, int limit = 10]) async {
    try {
      final publicList = await getUserListByType(userId, 'public-list');
      final privateList = await getUserListByType(userId, 'private-list');

      return Result.sucess([...publicList.data!, ...privateList.data!]);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<String>> addMusic({required String musicUUID, required String userId, required String listId, required String listType}) async {
    try {
      DocumentReference<Map<String,dynamic>> musicReference = firestoreContext.db.collection('Musics').doc(musicUUID);
      final listResult = await getOne(listId, [userId, listType]);
      if(!listResult.onSuccess) throw Exception(listResult.errorMessage!);
      listResult.data!.musics.add(musicReference);
      firestoreContext.updateOne(dataset, listResult.data!.toJson(), listId, [userId, listType]);
      return Result.sucess('Se ha agragado la musica con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<T>> getOne(String id, [List<String> queryArray = const []]) async {
    try {
      final data = await firestoreContext.getOne(dataset, id, queryArray);
      final result = data != null ? Result.sucess(MusicList.fromJson(data, queryArray[1])) : Result<T>.error('No se ha encontrado el elemento');
      if(!result.onSuccess) throw Exception(result.errorMessage);
      return result;
    } catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<String>> deleteOne(String id, [List<String> queryArray = const []]) {
    // TODO: implement deleteOne
    throw UnimplementedError();
  }

  @override
  Future<Result<T>> updateOne(MusicList data, String id, [List<String> queryArray = const []]) async {
    try {
      final retorno = await firestoreContext.updateOne(dataset, data.toJson(), id, queryArray);
      return Result.sucess(T.fromJson(retorno, queryArray[1]));
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }
  
}