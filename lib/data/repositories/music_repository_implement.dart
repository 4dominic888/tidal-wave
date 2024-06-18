import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tidal_wave/data/repositories/repository_implement_base.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/repositories/music_repository.dart';

class MusicRepositoryImplement extends RepositoryImplementBase with UseFirestore implements MusicRepository {

  MusicRepositoryImplement({required super.databaseService});

  @override
  String get dataset => 'Musics';

  @override
  Future<Result<T>> addOne(T data, String? id, [List<String> queryArray = const []]) async {
    try {
      if(id == null){
        await firestoreContext.addOne(dataset, data.toJson(), queryArray);
      } else{
        await firestoreContext.setOne(dataset, data.toJson(), id, queryArray);
      }
      return Result.sucess(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }    
  }

  @override
  Future<Result<List<T>>> getAll({List<String> queryArray = const [], bool Function(Map<String, dynamic> query)? where, int limit = 10}) async {
    try {
      int index = -1;
      final data = await firestoreContext.getAll(dataset, queryArray, where, limit);
      return Result.sucess(data.map((e) {
        index++;
        return T.fromJson(e,index);
      }).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<List<T>>> getAllByReferences(List<DocumentReference<Map<String, dynamic>>> references, {bool Function(Map<String, dynamic> query)? where, int limit = 10}) async {
    try {
      int index = -1;
      final data = await firestoreContext.getAllByReferences(references);
      return Result.sucess(data.map((e) {
        index++;
        return T.fromJson(e,index);
      }).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<String>> deleteOne(String id, [List<String> queryArray = const []]) {
    // TODO: implement deleteOne
    throw UnimplementedError();
  }

  @override
  Future<Result<T>> getOne(String id, [List<String> queryArray = const []]) {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Future<Result<T>> updateOne(T data, String id, [List<String> queryArray = const []]) {
    // TODO: implement updateOne
    throw UnimplementedError();
  }
  
}