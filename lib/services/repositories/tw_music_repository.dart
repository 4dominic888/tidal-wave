import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/services/repositories/repository_implement_base.dart';
import 'package:tidal_wave/data/result.dart';

typedef T = Music;

class TWMusicRepository extends RepositoryImplementBase<T> with OnlyFirestoreAction<T> implements Addable<T>, GetOneable<T>, GetAllable<T>, Updatable<T>, Deletable<T> {

  TWMusicRepository(super.type);

  @override
  String get dataset => 'Musics';

  @override
  Future<Result<T>> addOne(T data, String? id, [List<String> queryArray = const []]) async {
    try {
      actionDependingToDB(
        isFireStore: (firestoreContext) async {
          if(id == null){
            await firestoreContext.addOne(dataset, data.toJson(), queryArray);
          } else{
            await firestoreContext.setOne(dataset, data.toJson(), id, queryArray);
          }
        },
        isHive: (){
          //TODO implementar
          //* Agregar musicas meramente locales
          throw UnimplementedError();
        }
      );
      return Result.sucess(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }    
  }

  @override
  Future<Result<List<T>>> getAll({List<String> queryArray = const [], bool Function(Map<String, dynamic> query)? where, int limit = 10}) async {
    try {
      int index = -1;
      late final List<Map<String, dynamic>> data;
      actionDependingToDB(
        isFireStore: (firestoreContext) async {
          data = await firestoreContext.getAll(dataset, queryArray, where, limit);
        },
        isHive: (){
        //TODO implementar
        //* No se como maneje esto
        throw UnimplementedError();          
        }
      );
      return Result.sucess(data.map((e) {
        index++;
        return T.fromJson(e,index);
      } ).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  /// Solo para firebase
  Future<Result<List<T>>> getAllByReferences(List<DocumentReference<Map<String, dynamic>>> references, {bool Function(Map<String, dynamic> query)? where, int limit = 10}) async {
    try {
      int index = -1;
      late final List<Map<String, dynamic>> data;
      actionOnlyFirestore((firestoreContext) async => data = await firestoreContext.getAllByReferences(references));

      return Result.sucess(data.map((e) {
        index++;
        return T.fromJson(e,index);
      }).toList());
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