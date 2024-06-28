import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorUtil{

  /// Oscurece el color dado, en base al amount colocado
  static Color darken(Color color, {double amount = .1}){
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  /// Return a Dominan color & Constrast color in a array
  static Future<List<dynamic>> adjustColorBy({String? imgUrl}) async {
    
    final List<Color> dominanColors = [ const Color.fromARGB(255, 30, 114, 138),const Color(0xFF071A2C)];
    final Color constrastColor;

    if(imgUrl != null){
      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        //*TODO: Cambiar segun la disponibilidad a internet
        Image.file(File.fromUri(Uri.parse(imgUrl))).image,
        size: const Size(300, 300),
        maximumColorCount: 2
      );
      final int paletteLen = paletteGenerator.colors.length;
      for (int i = 0; i < paletteLen; i++) {
        dominanColors[i] = paletteGenerator.colors.elementAt(i);
      }
    }
    constrastColor = dominanColors.last.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    return [dominanColors, constrastColor];
  }
}