import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/repositories/music_repository.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';

class MusicManagerUseCaseImplement implements MusicManagerUseCase {
  
  final MusicRepository repo;

  MusicManagerUseCaseImplement(this.repo);

  @override
  Future<Result<String>> agregarMusica(Music musica, {required TypeOfOrigin type, String? id}) async {
    final result = await repo.addOne(musica, id);
    if(result.onSuccess) return Result.sucess('Musica agregada con exito');
    return Result.error(result.errorMessage!);
  }

  @override
  Future<Result<String>> actualizarMusica(Music musica, String id, {required TypeOfOrigin type}) async  {
    final result = await repo.updateOne(musica, id);
    if(result.onSuccess) return Result.sucess('Musica agregada con exito');
    return Result.error(result.errorMessage!);
  }

  @override
  Future<Result<String>> eliminarMusica(String id, {required TypeOfOrigin type}) async {
    return await repo.deleteOne(id);
  }

  @override
  Future<Result<List<Music>>> obtenerCancionesDeLista(MusicList list) async {
    return await repo.getAllByReferences(list.musics);
  }

  @override
  Future<Result<List<Music>>> obtenerCancionesPublicas({bool Function(Map<String, dynamic> query)? where, int limit = 10}) async {
    return await repo.getAll(where: where, limit: limit);
  }
  
}