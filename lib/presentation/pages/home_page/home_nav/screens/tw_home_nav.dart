import 'package:flutter/material.dart';
import 'package:tidal_wave/presentation/pages/home_page/home_nav/widgets/ad_container.dart';

class TWHomeNav extends StatelessWidget {
  const TWHomeNav({super.key});

  @override
  Widget build(BuildContext context) {

    return const SingleChildScrollView(
      child: Column(
        children: [
          AdContainer(
            text: 'Algun anuncio',
            description: 'Alguna descripcion',
            gradient: LinearGradient(colors: [Colors.blueAccent, Colors.pink]),
          ),

          SizedBox(height: 30),

          Text('Bienvenido a Tidal Wave', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}