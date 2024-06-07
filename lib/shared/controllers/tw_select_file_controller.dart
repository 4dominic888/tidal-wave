import 'dart:io';

import 'package:audio_duration/audio_duration.dart';
import 'package:flutter/material.dart';

class TWSelectFileController extends ChangeNotifier {
  File? _file;
  /// only if the file is audio
  Duration? musicDuration;
  Duration? clipMoment;

  set setValue(File? file){
    _file = file;
    notifyListeners();
  }

  void setAudio(File? file) async {
    _file = file;
    if(file == null) return;
    musicDuration = Duration(milliseconds: (await AudioDuration.getAudioDuration(file.path))!);
    notifyListeners();
  }

  File? get value => _file;
}