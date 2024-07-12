import 'package:flutter/services.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/data/abstractions/repository_implement_base.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/repositories/music_list_repository.dart';

class MusicListRepositoryImplement extends RepositoryImplementBase with UseFirestore, UseSqflite implements MusicListRepository{
  
  MusicListRepositoryImplement({required super.onlineContext, required super.offlineContext});

  @override
  //* Para local se usa para consultar las listas locales
  //* Para online se usa para las listas publicadas por el usuario
  String get dataset => 'UserListMusics';
  
  //* Tabla de relacion de muchos a muchos de listas a musicas
  static String manyToManyListMusicsLocal = 'MusicsLists';

  @override
  Future<Result<T>> addOne(MusicList data, [String? id]) async {
    try {
      data = data.copyWith(type: DataSourceType.local, musics: []);
      if(id == null){
        await offlinesqfliteContext.addOne(dataset, data.toJson());
      }
      else{
        await offlinesqfliteContext.setOne(dataset, data.toJson(), id);
      }
      return Result.success(data);
    } on Exception catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> addMusic({required String musicUUID, required String listId}) async {
    try {
      await offlinesqfliteContext.addManytoMany(manyToManyListMusicsLocal, {'music_id': musicUUID}, {'list_id': listId});
      return Result.success('Musica agregada con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> removeMusic({required String musicUUID, required String listId}) async {
    try {
      await offlinesqfliteContext.db.rawDelete('DELETE FROM $manyToManyListMusicsLocal WHERE music_id = ? AND list_id = ?', [musicUUID, listId]);
      return Result.success('Musica removida con exito de la lista');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> clearList(String listId) async {
    try {
      await offlinesqfliteContext.db.rawDelete('DELETE FROM $manyToManyListMusicsLocal WHERE list_id = ?', [listId]);
      return Result.success('Musica agregada con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<T>> getOne(String id, {List<String> queryArray = const []}) async {
    try {
      final Map<String, dynamic>? dataMap = await offlinesqfliteContext.getOne(dataset, id);
      
      if(dataMap == null) return Result<T>.error('No se ha encontrado el elemento');
      
      late final List<Map<String, dynamic>> musicsMap;
      final data = MusicList.fromJson(dataMap).copyWith(musics: []);

      //* Llenado de musicas a la lista

      musicsMap = await offlinesqfliteContext.db.rawQuery(await rootBundle.loadString('assets/raw_queries/select_locale_songs_by_list_id.sql'), [id]);
      
      int i = 0;
      data.musics!.addAll(musicsMap.map((music) {
        i++;
        return Music.fromJson(music, i);
      }));

      return Result.success(data);
    } catch (e) {
      return Result.error('Ha ocurrido un error: $e');
    }
  }

  @override
  Future<Result<bool>> updateOne(MusicList data, String id) async {
    try {
      await offlinesqfliteContext.updateOne(dataset, data.toJson(), id);
      return Result.success(true);
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> deleteOne(String id) async {
    try {
        await clearList(id);
        await offlinesqfliteContext.deleteOne(dataset, id);
      return Result.success('Se ha eliminado la lista con exito');

    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<List<T>>> getAllLocal({String? where, List<String>? whereArgs, int limit = 10}) async {
    try {
      final data = await offlinesqfliteContext.getAll(dataset, where:where, whereArgs:whereArgs, limit:limit);
      return Result.success(data.map((e) => T.fromJson(e)).toList());
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }
  
  @override
  Future<Result<List<T>>> getAllNonRepetitiveMusicAdded(String musicId) async {
    try {
      //* Consulta anidada de SELECT que retorna las listas que no contengan el musicID dado, ademas de mostrar las listas vacias
      final data = await offlinesqfliteContext.db.rawQuery(
        "SELECT * FROM $dataset WHERE uuid IN( SELECT list_id from $manyToManyListMusicsLocal WHERE list_id NOT IN( SELECT list_id FROM $manyToManyListMusicsLocal WHERE music_id = '$musicId' ) ) OR uuid IN( SELECT uuid FROM $dataset WHERE uuid NOT IN( SELECT list_id FROM $manyToManyListMusicsLocal) AND name != 'Favoritos')"
      );
      return Result.success(data.map((e) => T.fromJson(e)).toList());
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }    
  }


}