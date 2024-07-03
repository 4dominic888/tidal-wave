import 'package:tidal_wave/data/abstractions/save_file_local.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/data/utils/find_field_on_firebase.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/repositories/music_list_repository.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_list_manager_use_case.dart';
import 'package:uuid/uuid.dart';

class MusicListManagerUseCaseImplement with SaveFiles implements MusicListManagerUseCase{

  final MusicListRepository repo;

  MusicListManagerUseCaseImplement(this.repo);

  @override
  Future<Result<String>> agregarLista(MusicList lista, {void Function(double)? progressCallback}) async {
    try {
      final String uuid = const Uuid().v4();
      Uri? imageUri;
      if(lista.image != null) { 
        final uploadResult = await saveLocalFile(
          uri: lista.image!,
          folderName: 'list-thumb',
          newName: 'l-$uuid',
          progressCallback: progressCallback
        );
        if(!uploadResult.onSuccess) return Result.error(uploadResult.errorMessage!);
        imageUri = Uri.parse(uploadResult.data!);
      }

      final result = await repo.addOne(lista.copyWith(image: imageUri), uuid);
      if(!result.onSuccess) return Result.error(result.errorMessage!);

      return Result.success('Lista creada con exito');
      
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> editarLista(MusicList lista, String id) async {
    try {
      Uri? imageUri;
      if(lista.image != null) { 
        final uploadResult = await saveLocalFile(
          uri: lista.image!,
          folderName: 'list-thumb',
          newName: 'l-$id'
        );
        if(!uploadResult.onSuccess) return Result.error(uploadResult.errorMessage!);
        imageUri = Uri.parse(uploadResult.data!);
      }
      
      final result = await repo.updateOne(lista.copyWith(image: imageUri), id);
      if(!result.onSuccess) return Result.error(result.errorMessage!);
      
      return Result.success('Lista actualizada');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> eliminarLista(String id) async {
    try {
      final result = await repo.getOne(id);
      if(!result.onSuccess) return Result.error('Lista no encontrada para eliminar');

      if(result.data!.image != null) { deleteLocalFile(result.data!.image!); }

      return await repo.deleteOne(id);

    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<MusicList>> obtenerLista(String id, {DataSourceType type = DataSourceType.local}) async {
    try {
      return await repo.getOne(id, dataSourceType: type);
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<List<MusicList>>> obtenerListasLocales({String? where, List<String>? whereArgs, int limit = 10}) async {
    return await repo.getAllLocal(where: where, whereArgs: whereArgs, limit: limit);
  }

  @override
  Future<Result<List<MusicList>>> obtenerListasPublicas({FindManyFieldsToOneSearchFirebase? finder, int limit = 10}) async {
    return await repo.getAllGlobal(finder: finder, limit: limit);
  }
  
  @override
  Future<Result<List<MusicList>>> obtenerListasSubidas({FindManyFieldsToOneSearchFirebase? finder, int limit = 10}) async {
    return await repo.getAllUploaded(finder: finder, limit: limit);
  }

  @override
  Future<Result<String>> agregarMusicaALista({required String musicId, required String listId}) async {
    return await repo.addMusic(musicUUID: musicId, listId: listId);
  }
  
  @override
  Future<Result<String>> eliminarMusicaDeLista({required String musicId, required String listId}) async {
    return await repo.removeMusic(musicUUID: musicId, listId: listId);
  }
  
  @override
  Future<Result<String>> limpiarLista({required String listId}) async {
    return await repo.clearList(listId);
  }

}