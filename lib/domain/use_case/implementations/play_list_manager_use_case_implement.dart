import 'package:firebase_auth/firebase_auth.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/repositories/music_list_repository.dart';
import 'package:tidal_wave/domain/use_case/interfaces/play_list_manager_use_case.dart';

class PlayListManagerUseCaseImplement implements PlayListManagerUseCase{

  final MusicListRepository repo;

  PlayListManagerUseCaseImplement(this.repo);

  @override
  Future<Result<String>> agregarLista(MusicList lista, String? id) async {
    final result = await repo.addOne(lista, id);
    if(result.onSuccess) return Result.sucess('Lista creada con exito');
    return Result.error(result.errorMessage!);
  }

  @override
  Future<Result<String>> editarLista(MusicList lista, String id) async {
    final result = await repo.updateOne(lista, id);
    if(result.onSuccess) return Result.sucess('Lista actualizada');
    return Result.error(result.errorMessage!);
  }

  @override
  Future<Result<String>> eliminarLista(String id) async {
    return await repo.deleteOne(id);
  }

  @override
  Future<Result<List<MusicList>>> obtenerListasDeUsuarioActual() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if(userId == null) return Result.error('Se debe especificar un usuario');
    return await repo.getAllListForUser(userId);
  }

  @override
  Future<Result<List<MusicList>>> obtenerListasPublicas({bool Function(Map<String, dynamic> query)? where, int limit = 10}) {
    // TODO: implement obtenerListasPublicas
    throw UnimplementedError();
  }

  @override
  Future<Result<String>> agregarMusicaALista({required String musicUUID, required String userId, required String listId, required String listType}) async {
    return await repo.addMusic(musicUUID: musicUUID, userId: userId, listId: listId, listType: listType);
  }

}