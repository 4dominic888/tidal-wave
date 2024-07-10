import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/data/utils/find_field_on_firebase.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/repositories/crud_interfaces.dart';

typedef T = MusicList;

abstract class MusicListRepository implements Addable<T>, GetOneable<T>, Updatable<T>, Deletable{
  
  /// Agrega una lista de musicas vacia, siempre se crea de manera local
  @override Future<Result<T>> addOne(MusicList data, [String? id]);

  /// Obtienes una lista de musicas, ya sea local o subida en la nube especificado en `dataSourceType`
  @override Future<Result<T>> getOne(String id, {DataSourceType dataSourceType});

  /// Actualiza una lista de musicas solo de manera local
  /// 
  /// Solo se limita a cambiar la metadata, y no las musicas, ya que estas se cambian con otros metodos como `addMusic`
  @override Future<Result<bool>> updateOne(MusicList data, String id);

  /// Se elimina una lista SOLO de manera local, para borrar una lista publicada, ver `removePublishList`
  @override Future<Result<String>> deleteOne(String id);

  /// Obtiene todas las listas locales
  Future<Result<List<T>>> getAllLocal({String? where, List<String>? whereArgs, int limit = 10});
  
  /// Obtiene todas las listas a excepcion de las listas donde la musica ha sido agregada segun el 'musicId' ingresado
  Future<Result<List<T>>> getAllNonRepetitiveMusicAdded(String musicId);
  
  /// Obtiene todas las listas subidas por el usuario a la nube
  Future<Result<List<T>>> getAllUploaded({FindManyFieldsToOneSearchFirebase? finder, int limit = 10});
  
  /// Obtiene todas las listas existentes en la nube subidas por todos los usuarios
  Future<Result<List<T>>> getAllGlobal({List<String> queryArray = const [], FindManyFieldsToOneSearchFirebase? finder, int limit = 10});

  /// Agrega una musica a la lista, solo de manera local
  Future<Result<String>> addMusic({required String musicUUID, required String listId});

  /// Remueve una musica de la lista, solo de manera local
  Future<Result<String>> removeMusic({required String musicUUID, required String listId});

  /// Limpia toda la lista, solo de manera local
  Future<Result<String>> clearList(String listId);
  
  /// Publica la lista a la nube, se omite la subida de las canciones colocadas por el usuario de manera local
  Future<Result<String>> publishList(MusicList list);

  /// Actualiza la lista de la nube, se omiten la subida de las canciones colocadas por el usuario de manera local
  Future<Result<String>> rePublishList(MusicList list, String id);

  /// Remueve la lista de la nube, pero no borra la lista local existente.
  Future<Result<String>> removePublishList(String listId);
}