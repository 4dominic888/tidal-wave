import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/models/music_list.dart';

enum TypeOfOrigin{
  global,
  local
}

abstract class MusicManagerUseCase {
  Future<Result<List<Music>>> obtenerCancionesPublicas({bool Function(Map<String, dynamic> query)? where, int limit = 10});
  Future<Result<String>> agregarMusica(Music musica, {required TypeOfOrigin type, String? id});
  Future<Result<String>> actualizarMusica(Music musica, String id, {required TypeOfOrigin type});
  Future<Result<String>> eliminarMusica(String id, {required TypeOfOrigin type});
  Future<Result<List<Music>>> obtenerCancionesDeLista(MusicList list);
}