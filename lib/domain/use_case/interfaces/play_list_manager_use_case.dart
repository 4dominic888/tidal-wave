import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/music_list.dart';

abstract class PlayListManagerUseCase{
  Future<Result<String>> agregarLista(MusicList lista, String? id);
  Future<Result<String>> editarLista(MusicList lista, String id);
  Future<Result<String>> eliminarLista(String id);
  Future<Result<String>> agregarMusicaALista({required String musicUUID, required String userId, required String listId, required String listType});
  Future<Result<List<MusicList>>> obtenerListasPublicas({bool Function(Map<String, dynamic> query)? where, int limit = 10});
  Future<Result<List<MusicList>>> obtenerListasDeUsuarioActual();
}