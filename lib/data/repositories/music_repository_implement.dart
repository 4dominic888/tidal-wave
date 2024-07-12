import 'package:sqflite/sqflite.dart';
import 'package:tidal_wave/data/abstractions/repository_implement_base.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/data/utils/find_field_on_firebase.dart';
import 'package:tidal_wave/domain/repositories/music_repository.dart';

class MusicRepositoryImplement extends RepositoryImplementBase with UseFirestore, UseSqflite implements MusicRepository {

  MusicRepositoryImplement({required super.onlineContext, required super.offlineContext});

  @override
  String get dataset => 'Musics';

  @override
  Future<Result<T>> addOne(T data, [String? id]) async {
    try {
      if(id == null){
        await offlinesqfliteContext.addOne(dataset, data.toJsonLocal());
      } else{
        await offlinesqfliteContext.setOne(dataset, data.toJsonLocal(), id);
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
        await onlinefirestoreContext.addOne(dataset, oData.toJson(), queryArray);
      } else{
        await onlinefirestoreContext.setOne(dataset, oData.toJson(), id, queryArray);
      }
      return Result.success(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }    
  }

  @override
  Future<Result<List<T>>> getAllOnline({List<String> queryArray = const [], FindManyFieldsToOneSearchFirebase? finder, T? lastItem, int limit = 10}) async {
    try {
      final data = await onlinefirestoreContext.getAll(dataset,
        queryArray, finder,
        lastItem?.uploadAt.millisecondsSinceEpoch,
        limit
      );
      return Result.success(data.map((e) => T.fromJson(e,0)).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<List<T>>> getAllLocal({String? where, List<String>? whereArgs, int limit = 10, int page = 0}) async {
    try {
      final data = await offlinesqfliteContext.getAll(dataset, where: where, whereArgs: whereArgs, limit: limit, page: page);
      return Result.success(data.map((e) => T.fromJson(e,0)).toList());
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<T>> getOne(String id, {DataSourceType dataSourceType = DataSourceType.local}) async {
    try {
      final Map<String, dynamic>? data = dataSourceType == DataSourceType.local ? await offlinesqfliteContext.getOne(dataset, id) : await onlinefirestoreContext.getOne(dataset, id);
      if(data == null) throw Exception('Musica no encontrada');
      return Result.success(T.fromJson(data, 0));
    } catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<bool>> updateOne(T data, String id) async {
    try {
      await offlinesqfliteContext.updateOne(dataset, data.toJsonLocal(), id);
      return Result.success(true);
    } catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<String>> deleteOne(String id) async {
    try {
      await offlinesqfliteContext.db.rawDelete('DELETE FROM MusicsLists WHERE music_id = ?', [id]);
      await offlinesqfliteContext.deleteOne(dataset, id);
      return Result.success('Se ha eleminado el elemento con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }
  
  @override
  Future<bool> existingId(String uuid) async {
    final result = await offlinesqfliteContext.db.rawQuery('SELECT COUNT(*) as count FROM $dataset WHERE uuid = ?', [uuid]);
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
  
}