import 'package:tidal_wave/data/abstractions/repository_implement_base.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/repositories/music_repository.dart';

class MusicRepositoryImplement extends RepositoryImplementBase with UseFirestore, UseSqflite implements MusicRepository {

  MusicRepositoryImplement({required super.databaseService});

  @override
  String get dataset => 'Musics';

  @override
  Future<Result<T>> addOne(T data, [String? id]) async {
    try {
      final lData = data.copyWith(type: DataSourceType.local);
      if(id == null){
        await sqfliteContext.addOne(dataset, lData.toJson());
      } else{
        await sqfliteContext.setOne(dataset, lData.toJson(), id);
      }
      return Result.success(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }    
  }

  @override
  Future<Result<T>> upload(T data, String? id, [List<String> queryArray = const []]) async {
    try {
      final oData = data.copyWith(type: DataSourceType.online);
      if(id == null){
        await firestoreContext.addOne(dataset, oData.toJson(), queryArray);
      } else{
        await firestoreContext.setOne(dataset, oData.toJson(), id, queryArray);
      }
      return Result.success(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }    
  }

  @override
  Future<Result<List<T>>> getAllOnline({List<String> queryArray = const [], bool Function(Map<String, dynamic> query)? where, int limit = 10}) async {
    try {
      final data = await firestoreContext.getAll(dataset, queryArray, where, limit);
      return Result.success(data.map((e) => T.fromJson(e,0)).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<List<T>>> getAllLocal({String? where, List<String>? whereArgs, int limit = 10}) async {
    try {
      final data = await sqfliteContext.getAll(dataset, where: where, whereArgs: whereArgs, limit: limit);
      return Result.success(data.map((e) => T.fromJson(e,0)).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<T>> getOne(String id, {DataSourceType dataSourceType = DataSourceType.local}) async {
    try {
      final Map<String, dynamic>? data = dataSourceType == DataSourceType.local ? await sqfliteContext.getOne(dataset, id) : await firestoreContext.getOne(dataset, id);
      if(data == null) throw Exception('Musica no encontrada');
      return Result.success(T.fromJson(data, 0));
    } catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<bool>> updateOne(T data, String id) async {
    try {
      await sqfliteContext.updateOne(dataset, data.toJson(), id);
      return Result.success(true);
    } catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<String>> deleteOne(String id) async {
    try {
      await sqfliteContext.db.rawDelete('DELETE FROM MusicsLists WHERE music_id = ?', [id]);
      await sqfliteContext.deleteOne(dataset, id);
      return Result.success('Se ha eleminado el elemento con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
  
}