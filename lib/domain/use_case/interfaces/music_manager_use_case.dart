import 'package:firebase_storage/firebase_storage.dart';
import 'package:tidal_wave/data/abstractions/save_file_local.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/data/utils/find_firebase.dart';
import 'package:tidal_wave/domain/models/music.dart';


abstract class MusicManagerUseCase {
  //TODO: quitar luego
  Future<Result<String>> subirMusicaOnline(Music musica, {void Function(TaskSnapshot)? onLoadImagen, void Function(TaskSnapshot)? onLoadMusic});
  Future<Result<String>> agregarMusica(Music musica);
  Future<Result<String>> editarMusica(Music musica, String id, {required DataSourceType type});
  Future<Result<String>> eliminarMusica(String id, {required DataSourceType type});

  Future<Result<String>> descargarMusica(String id, {ProgressOfDownload? progressOfDownload});
  
  Future<Result<List<Music>>> obtenerMusicasPublicas({FindManyFieldsToOneSearchFirebase? finder, Music? lastItem, int limit = 10});
  Future<Result<List<Music>>> obtenerMusicasDescargadas({String? where, List<String>? whereArgs, int limit = 10});

  Future<bool> musicaExistente(String uuid);
}