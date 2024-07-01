import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/data/utils/find_firebase.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/repositories/crud_interfaces.dart';

typedef T = Music;

abstract class MusicRepository implements Addable<T>, GetOneable<T>, Updatable<T>, Deletable{
  
  /// Agrega una musica de manera local
  @override Future<Result<T>> addOne(T data, [String? id]);

  /// Obtiene una musica ya sea local o en la nube segun `dataSourceType`
  @override Future<Result<T>> getOne(String id, {DataSourceType dataSourceType});

  /// Actualiza una musica solo de manera local
  @override Future<Result<bool>> updateOne(T data, String id);

  /// Elimina una musica de manera local.
  @override Future<Result<String>> deleteOne(String id);

  /// Obtiene todas las musicas subidas disponibles en la nube.
  Future<Result<List<T>>> getAllOnline({FindManyFieldsToOneSearchFirebase? finder, T? lastItem, int limit = 10});
  
  /// Obtiene todas las musicas locales que tenga el usuario, osea las descargadas.
  Future<Result<List<T>>> getAllLocal({String? where, List<String>? whereArgs, int limit = 10});
  
  /// Sube una cancion a la nube
  /// TODO: Quitar luego
  Future<Result<T>> upload(T data, String? id);

  Future<bool> existingId(String uuid);
}