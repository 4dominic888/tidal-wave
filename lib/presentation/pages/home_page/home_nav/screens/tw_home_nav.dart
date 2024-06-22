import 'package:flutter/material.dart';
import 'package:tidal_wave/presentation/pages/home_page/home_nav/widgets/ad_container.dart';
import 'package:tidal_wave/presentation/pages/reproductor_musica/widgets/media_meta_data.dart';

class TWHomeNav extends StatelessWidget {
  const TWHomeNav({super.key});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          const AdContainer(
            text: 'Algun anuncio',
            description: 'Alguna descripcion',
            gradient: LinearGradient(colors: [Colors.blueAccent, Colors.pink]),
          ),

          const SizedBox(height: 30),

          const Text('Musicas destacadas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              children: List.generate(8, (_) => 
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: (){},
                      highlightColor: Colors.white,
                      child: const MediaMetaData(
                        sizePercent: 0.5,
                          title: 'title',
                          artist: 'artist',
                          color: Colors.white
                        ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Text('Under in construction...', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}