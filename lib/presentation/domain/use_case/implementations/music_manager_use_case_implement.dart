import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:tidal_wave/data/abstractions/save_file_local.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/dataSources/firebase/firebase_storage_service.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/repositories/music_repository.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';
import 'package:uuid/uuid.dart';

class MusicManagerUseCaseImplement with SaveFiles implements MusicManagerUseCase {
  
  final MusicRepository repo;

  MusicManagerUseCaseImplement(this.repo);

  @override
  Future<Result<String>> subirMusicaOnline(Music musica, {void Function(TaskSnapshot)? onLoadImagen, void Function(TaskSnapshot)? onLoadMusic}) async {
    try {
      final String uuid = const Uuid().v4();

      Uri? imageUri;
      final Uri musicUri;

      final uploadMusicResult = await FirebaseStorageService.uploadFile(
        'music',
        'm-$uuid',
        File.fromUri(musica.musica),
        onLoad: onLoadMusic
      );
      if(!uploadMusicResult.onSuccess) return Result.error(uploadMusicResult.errorMessage!);
      musicUri = Uri.parse(uploadMusicResult.data!);

      if(musica.imagen != null){
        final uploadImagenResult = await FirebaseStorageService.uploadFile(
          'music-thumb',
          'i-$uuid',
          File.fromUri(musica.imagen!),
          onLoad: onLoadImagen 
        );
        if(!uploadImagenResult.onSuccess) return Result.error(uploadImagenResult.errorMessage!);
        imageUri = Uri.parse(uploadImagenResult.data!);
      }

      final result = await repo.upload(musica.copyWith(
        imagen: imageUri,
        musica: musicUri
      ), uuid);
      if(!result.onSuccess) return Result.error(result.errorMessage!);
      return Result.success('Se ha subido correctamente la musica a los servidores');

    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> agregarMusica(Music musica) async {
    try {
      final String uuid = const Uuid().v4();
      
      Uri? imageUri;
      final Uri musicUri;

      final uploadMusicResult = await saveLocalFile(
        uri: musica.musica,
        folderName: 'music',
        newName: 'm-$uuid'
      );
      if(!uploadMusicResult.onSuccess) return Result.error(uploadMusicResult.errorMessage!);
      musicUri = Uri.parse(uploadMusicResult.data!);

      if(musica.imagen != null) { 
        final uploadImageResult = await saveLocalFile(
          uri: musica.imagen!,
          folderName: 'music-thumb',
          newName: 'i-$uuid'
        );
        if(!uploadImageResult.onSuccess) return Result.error(uploadImageResult.errorMessage!);
        imageUri = Uri.parse(uploadImageResult.data!);
      }

      final result = await repo.addOne(musica.copyWith(
        imagen: imageUri,
        musica: musicUri
      ), uuid);

      if(!result.onSuccess) return Result.error(result.errorMessage!);
      return Result.success('Musica agregada con exito');

    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> editarMusica(Music musica, String id, {required DataSourceType type}) async {
    try {
      Uri? imageUri;
      final Uri musicUri;

      final uploadMusicResult = await saveLocalFile(
        uri: musica.musica,
        folderName: 'music',
        newName: 'm-${musica.uuid}'
      );
      if(!uploadMusicResult.onSuccess) return Result.error(uploadMusicResult.errorMessage!);
      musicUri = Uri.parse(uploadMusicResult.data!);

      if(musica.imagen != null) { 
        final uploadImageResult = await saveLocalFile(
          uri: musica.imagen!,
          folderName: 'music-thumb',
          newName: 'i-${musica.uuid}'
        );
        if(!uploadImageResult.onSuccess) return Result.error(uploadImageResult.errorMessage!);
        imageUri = Uri.parse(uploadImageResult.data!);
      }

      final result = await repo.updateOne(musica.copyWith(
        imagen: imageUri,
        musica: musicUri
      ), id);
      if(result.onSuccess) return Result.error(result.errorMessage!);
      return Result.success('Musica actualizada con exito');
      
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<String>> eliminarMusica(String id, {required DataSourceType type}) async {
    try {
      final musicaResult = await repo.getOne(id);
      if(!musicaResult.onSuccess) return Result.error(musicaResult.errorMessage!);
      final musica = musicaResult.data!;

      if(musica.imagen != null) { 
        await deleteLocalFile(musica.imagen!);
      }
      await deleteLocalFile(musica.musica);

      return await repo.deleteOne(id);
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }

  @override
  Future<Result<List<Music>>> obtenerMusicasPublicas({bool Function(Map<String, dynamic> query)? where, Music? lastItem, int limit = 10}) async {
    return await repo.getAllOnline(where: where, lastItem: lastItem, limit: limit);
  }
  
  @override
  Future<Result<List<Music>>> obtenerMusicasDescargadas({String? where, List<String>? whereArgs, int limit = 10}) async {
    return await repo.getAllLocal(where: where, whereArgs: whereArgs, limit: limit);
  }
  
  @override
  Future<Result<String>> descargarMusica(String id, {ProgressOfDownload? progressOfDownload}) async {
    try {
      final musicResult = await repo.getOne(id, dataSourceType: DataSourceType.online);
      if(!musicResult.onSuccess) return Result.error(musicResult.errorMessage!);
      
      late final Uri? musicImageUri;
      final Uri musicUri;

      //* Descargar imagen
      if(musicResult.data!.imagen != null){
        final musicImagePathResult = await saveOnlineFile(
          uri: musicResult.data!.imagen!,
          folderName: 'music-thumb',
          fileName: 'i-${musicResult.data!.uuid}',
          progressOfDownload: progressOfDownload ?? (int total, int downloaded, double progress){}
        );
        if(!musicImagePathResult.onSuccess) return Result.error(musicImagePathResult.errorMessage!);
        musicImageUri = Uri.parse(musicImagePathResult.data!);
      }

      //* Descargar cancion
      final musicPathResult = await saveOnlineFile(
        uri: musicResult.data!.musica,
        folderName: 'music',
        fileName: 'm-${musicResult.data!.uuid}',
        progressOfDownload: progressOfDownload ?? (int total, int downloaded, double progress){}
      );

      if(!musicPathResult.onSuccess) return Result.error(musicPathResult.errorMessage!);
      musicUri = Uri.parse(musicPathResult.data!);

      final Music musicOffline = musicResult.data!.copyWith(
        imagen: musicImageUri,
        musica: musicUri,
        type: DataSourceType.fromOnline
      );

      await repo.addOne(musicOffline, musicOffline.uuid);
      return Result.success('La musica ha sido descargada con exito');
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }
  
  @override
  Future<bool> musicaExistente(String uuid) async{
    return repo.existingId(uuid);
  }
}