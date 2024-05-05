import 'package:flutter/material.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/text_field_find.dart';

class ListaMusicaScreen extends StatefulWidget {
  const ListaMusicaScreen({super.key});

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
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 30, 114, 138),Color(0xFF071A2C)]
          )
        ),
      )
    );
  }
}