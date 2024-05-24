import 'dart:io';

import 'package:flutter/material.dart';

class TWSelectFileController extends ChangeNotifier {
  File? _file;

  set setValue(File? file){
    _file = file;
    notifyListeners();
  }

  File? get value => _file;
}