import 'package:flutter/material.dart';
import 'package:tidal_wave/modules/reproductor_musica/widgets/media_meta_data.dart';

class TWHomeNav extends StatelessWidget {
  const TWHomeNav({super.key});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blueAccent, Colors.pink]),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  spreadRadius: 10,
                  blurRadius: 20,
                )
              ]
            ),
            width: MediaQuery.of(context).size.width,
            height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Algun anuncio', 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                    )
                  ),

                  const SizedBox(height: 10),

                  const Text('Alguna descripcion adicional sobre el anuncio a presentar...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15
                    )
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: (){},
                    child: const Text('Some action button')
                  ),
                  TextButton(onPressed: (){}, child: const Text('Another action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                ],
              )
          ),

          const SizedBox(height: 30),

          const Text('Musicas destacadas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
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
          const Text('Under in construction...', style: TextStyle(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }
}