import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/music_item.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/text_field_find.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';

class ListaMusicaScreen extends StatefulWidget {

  final List<Music> listado;

  const ListaMusicaScreen({super.key, required this.listado});

  @override
  State<ListaMusicaScreen> createState() => _ListaMusicaScreenState();
}

class _ListaMusicaScreenState extends State<ListaMusicaScreen> {

  List<Widget> _appBarWidgets(){
    return [
      const SizedBox(width: 10),

      IconButtonUIMusic(
        borderColor: Colors.blue.shade400.withAlpha(50),
        borderSize: 4.0,
        fillColor: Colors.transparent,
        icon: const Icon(Icons.menu, size: 25, color: Colors.white),
        onTap: () {},
      ),
      
      const SizedBox(width: 5),

      Expanded(
        child: TextFieldFind(
          hintText:'Buscar cancion...',
          suffixIcon: IconButtonUIMusic(
            borderColor: Colors.blue.shade400.withAlpha(50),
            borderSize: 2.0,
            fillColor: Colors.transparent,
            icon: const Icon(Icons.search, size: 25, color: Colors.white),
            onTap: () {},
          ),
        )
      ),

      const SizedBox(width: 20),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80,
        actions: _appBarWidgets(),
        backgroundColor: Colors.transparent,
        elevation: 1,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 30, 114, 138),Color(0xFF071A2C)]
          )
        ),
        
        child: Stack(
          children: [
            Positioned(
              right: 10,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: widget.listado.length,
                  itemBuilder: (context, index) {
                        
                    final musica = widget.listado[index];
                    return MusicItem(music: musica);
                }),
              ),
            ),
          ],
        ),
      )
    );
  }
}