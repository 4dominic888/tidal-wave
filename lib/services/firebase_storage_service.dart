import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:tidal_wave/shared/result.dart';

class FirebaseStorageService {
  
  static final _storage = FirebaseStorage.instance;

  /// Return the downloadURL
  static Future<Result<String>> uploadFile(String folderName, String fileName, File file) async {

    try {
      final Reference fileReference = _storage.ref().child(folderName).child(fileName);
      await fileReference.putFile(file);
      return Result.sucess(await fileReference.getDownloadURL());
    } on FirebaseException catch (e) {
      return Result.error('${e.code} | ${e.message}');
    }

  }

  static Future<void> deleteFileWithURL(String url) async {
    await _storage.refFromURL(url).delete();
  }

}