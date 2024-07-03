import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/utils/find_field_on_firebase.dart';
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

  //* Solo funciona para online y sirve a modo de almacen global de todas las listas de todos los usuarios
  static String publicListsDataset = 'Lists';

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
      await offlinesqfliteContext.db.rawDelete('DELETE FROM MusicsLists WHERE music_id = ? AND list_id = ?', [musicUUID, listId]);
      return Result.success('Musica agregada con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> clearList(String listId) async {
    try {
      await offlinesqfliteContext.db.rawDelete('DELETE FROM MusicsLists WHERE list_id = ?', [listId]);
      return Result.success('Musica agregada con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<T>> getOne(String id, {DataSourceType dataSourceType = DataSourceType.local, List<String> queryArray = const []}) async {
    try {
      final isLocal = dataSourceType == DataSourceType.local;
      final Map<String, dynamic>? dataMap = isLocal ? 
        await offlinesqfliteContext.getOne(dataset, id):
        await onlinefirestoreContext.getOne(publicListsDataset, id, queryArray);
      
      if(dataMap == null) return Result<T>.error('No se ha encontrado el elemento');
      
      late final List<Map<String, dynamic>> musicsMap;
      final data = MusicList.fromJson(dataMap).copyWith(musics: []);

      //* Llenado de musicas a la lista
      if(isLocal){
        musicsMap = await offlinesqfliteContext.db.rawQuery(await rootBundle.loadString('assets/raw_queries/select_locale_songs_by_list_id.sql'), [id]);
      }
      else{
        musicsMap = await onlinefirestoreContext.getAllByReferences(dataMap['musics'] as List<DocumentReference>);
      }

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
  Future<Result<List<T>>> getAllLocal({String? where, List<String>? whereArgs, int? limit = 10}) async {
    try {
      final data = await offlinesqfliteContext.getAll(dataset, where:where, whereArgs:whereArgs, limit:limit);
      return Result.success(data.map((e) => T.fromJson(e)).toList());
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }
  
  @override
  Future<Result<List<T>>> getAllGlobal({List<String> queryArray = const [], FindManyFieldsToOneSearchFirebase? finder, int limit = 10}) async {
    try {
    final data = await onlinefirestoreContext.getAll(publicListsDataset, queryArray, finder, limit);
      return Result.success(data.map((e) => T.fromJson(e)).toList());
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<List<T>>> getAllUploaded({FindManyFieldsToOneSearchFirebase? finder, int? limit = 10}) async {
    try {
      final data = await onlinefirestoreContext.getOne(dataset, FirebaseAuth.instance.currentUser!.uid);
      if(data == null) throw Exception('Elemento no encontrado');
      final lists = await Future.wait(
        (data['lists'] as List<DocumentReference>).map((ref) async => (await ref.get()).data() as Map<String, dynamic>)
      );

      return Result.success(lists.map((e) => T.fromJson(e)).toList());
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> publishList(MusicList list) async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;

      //* Subir la metadata al servidor
      await onlinefirestoreContext.setOne(publicListsDataset, list.toJson()..addAll(
        {
          'upload by': onlinefirestoreContext.db.collection('Users').doc(userUid),
          
          'musics': list.musics?.where((m) => m.type == DataSourceType.fromOnline).map(
            (e) => onlinefirestoreContext.db.collection('Musics').doc(e.uuid)
          ).toList()
        }
      ), list.id);
      await updateOne(list, list.id);
      
      /*
      * Pasa la referencia de la lista en una coleccion generica para que el usuario vea sus listas subidas,
      * para no realizar una consulta compleja y costosa
      */
      await onlinefirestoreContext.addElementToArray<DocumentReference>(dataset, userUid, 'lists',
        FirebaseFirestore.instance.collection(publicListsDataset).doc(list.id)
      );
      
      return Result.success('Lista publicada con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }
  
  @override
  Future<Result<String>> removePublishList(String listId) async {
    try {
      await onlinefirestoreContext.removeElementToArray<DocumentReference>(dataset, FirebaseAuth.instance.currentUser!.uid, 'lists',
        FirebaseFirestore.instance.collection(publicListsDataset).doc(listId)
      );
      
      await onlinefirestoreContext.deleteOne(dataset, listId);
      return Result.success('Lista removida del servidor');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }
  
  @override
  Future<Result<String>> rePublishList(MusicList list, String id, {List<String> queryArray = const []}) async {
    try {
      await onlinefirestoreContext.updateOne(
        publicListsDataset,
        list.toJson()..addAll({
          'musics': list.musics?.where((m) => m.type == DataSourceType.fromOnline).map(
            (e) => onlinefirestoreContext.db.collection('Musics').doc(e.uuid)
          ).toList()
        }),
        id, queryArray
      );
      return Result.success('Lista re publicada con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');    
    }
  }
}