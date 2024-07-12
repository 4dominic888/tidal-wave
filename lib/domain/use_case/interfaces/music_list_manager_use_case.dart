import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/data/utils/find_field_on_firebase.dart';
import 'package:tidal_wave/domain/models/music_list.dart';

abstract class MusicListManagerUseCase{
  Future<Result<String>> agregarLista(MusicList lista, {void Function(double)? progressCallback});
  Future<Result<String>> editarLista(MusicList lista, String id);
  Future<Result<String>> eliminarLista(String id);
  Future<Result<MusicList>> obtenerLista(String id, {DataSourceType type});

  Future<Result<String>> agregarMusicaALista({required String musicId, required String listId});
  Future<Result<String>> eliminarMusicaDeLista({required String musicId, required String listId});
  Future<Result<String>> limpiarLista({required String listId});

  Future<Result<List<MusicList>>> obtenerListasPublicas({FindManyFieldsToOneSearchFirebase? finder, int limit = 10});

  Future<Result<List<MusicList>>> obtenerListasLocales({String? where, List<String>? whereArgs, int limit = 10});
  Future<Result<List<MusicList>>> obtenerListasSinMusicaAColocar(String musicId);
  Future<Result<List<MusicList>>> obtenerListasSubidas({FindManyFieldsToOneSearchFirebase? finder, int limit = 10});
}