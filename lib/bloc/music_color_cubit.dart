import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidal_wave/shared/color_util.dart';

/// Cubit para guardar colores importantes autogenerados
class MusicColorCubit extends Cubit<ImportantColors> {

  MusicColorCubit() : super(ImportantColors(
    const Color.fromARGB(255, 30, 114, 138), 
    const Color(0xFF071A2C), Colors.white));


  set colors(ImportantColors colors) {
    emit(colors);
  }

  Future<ImportantColors> updateByImgUrl({String? url}) async{
    
    final aux = await ColorUtil.adjustColorBy(imgUrl: url);

    state.dominanColor1 = aux[0][0];
    state.dominanColor2 = aux[0][1];
    state.constrastColor = aux[1];

    return(ImportantColors(state.dominanColor1, state.dominanColor2, state.constrastColor));
  }

  void update(Color dominanColor1, Color dominanColor2, Color constrastColor) {
      emit(ImportantColors(dominanColor1, dominanColor2, constrastColor));
  }
}

class ImportantColors {
  Color dominanColor1;
  Color dominanColor2;
  Color constrastColor;

  ImportantColors(this.dominanColor1, this.dominanColor2, this.constrastColor);

  @override
  String toString() {
    return """$dominanColor1
    $dominanColor2
    $constrastColor""";
  }
}