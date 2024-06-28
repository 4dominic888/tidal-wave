import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tidal_wave/data/result.dart';

typedef ProgressOfDownload = void Function(int total, int downloaded, double progress);
mixin SaveFiles{
  /// Obtiene la carpeta especifica para guardar los archivos, se creara o hara referencia a la subcarpeta definida por `nameFolder`
  Future<String> _pathToLocalFiles(String folderName) async{
    String? userUid = FirebaseAuth.instance.currentUser?.uid;
    if(userUid == null) throw Exception('Debes ser un usuario para acceder a esta funcionalidad');

    final Directory mainDir = Directory('${(await getApplicationDocumentsDirectory()).path}/twFiles');

    final Directory userDir = Directory('$mainDir/$userUid');
    if(!(await userDir.exists())){
      await userDir.create();
    }
    final Directory customDir = Directory('${userDir.path}/$folderName');
    if(!(await customDir.exists())){
      await customDir.create();
    }
    return customDir.path;
  }

  /// Regresa la nueva ruta copiada segun el `uri` colocado
  Future<Result<String>> saveLocalFile({required Uri uri, required String folderName, String? newName, void Function(double)? progressCallback}) async {
    final File file = File.fromUri(uri);
    final finalName = newName ?? basename(file.path);
    final ext = extension(file.path);
    IOSink? destinationSink;

    try {
      final folder = await _pathToLocalFiles(folderName);
      final folderWithFileName = '$folder/$finalName$ext';
      destinationSink = File(folderWithFileName).openWrite();

      int totalBytes = await file.length();
      Stream<List<int>> inputStream = file.openRead();
      int bytesCopied = 0;

      await for(var data in inputStream){
        destinationSink.add(data);
        bytesCopied += data.length;
        double progress = bytesCopied / totalBytes;
        progressCallback?.call(progress);
      }

      await destinationSink.close();
      
      // final finalPath = ( await file.copy('$folder/$finalName$ext') ).path;
      return Result.success(folderWithFileName);
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
    finally{
      destinationSink?.close();
    }
  }

  /// Elimina el archivo en base a la `uri`
  Future<void> deleteLocalFile(Uri uri) async {
    await File.fromUri(uri).delete();
  }

  Future<Uint8List> _downloadFile({required Uri uri, required ProgressOfDownload progressOfDownload}) async {
    final completer = Completer<Uint8List>();
    final response = http.Client().send(http.Request('GET', uri));

    int downloadedBytes = 0;
    List<List<int>> chunkList = [];
    response.asStream().listen((streamedResponse) {
      streamedResponse.stream.listen(
        (chunk) {
          final contentLenght = streamedResponse.contentLength ?? 0;
          final progress = (downloadedBytes / contentLenght) * 100;
          progressOfDownload(contentLenght, downloadedBytes, progress);
          chunkList.add(chunk);
          downloadedBytes += chunk.length;
        },
        onDone: () {
          final contentLenght = streamedResponse.contentLength ?? 0;
          final progress = (downloadedBytes / contentLenght) * 100;
          progressOfDownload(contentLenght, downloadedBytes, progress);

          int start = 0;
          final bytes = Uint8List(contentLenght);
          for (var c in chunkList) {
            bytes.setRange(start, start+c.length, c);
            start += c.length;
          }
          
          completer.complete(bytes);
        },
        onError: (error)=> completer.complete(error)
      );
    });

    return completer.future;
  }

  Future<Result<String>> saveOnlineFile({required Uri uri, required String folderName, required String fileName, required ProgressOfDownload progressOfDownload}) async {
    try {
      final folderBase = await _pathToLocalFiles(folderName);
      File file = File(join(folderBase, '$fileName${extension(uri.toString())}'));
      file.writeAsBytes(await _downloadFile(uri: uri, progressOfDownload: progressOfDownload));
      return Result.success(file.path);
    } catch (e) {
      return Result.error('Ha ocurrido un error $e');
    }
  }
}