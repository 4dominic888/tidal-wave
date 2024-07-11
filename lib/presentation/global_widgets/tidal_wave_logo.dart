import 'package:flutter/material.dart';

class TidalWaveLogo extends StatelessWidget {

  final double size;

  const TidalWaveLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/placeholder/tidal_wave_logo.png',
      width: size,
      height: size,
    );
  }
}