import 'package:flutter/material.dart';
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

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

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

  //TODO: Agregar funcionalidad de extraer mas datos de la base de datos a medida que se baja
  void _scrollListener(){
    const offset = 10;
    if(_scrollController.offset > offset && !_isScrolled){
      setState(() {
        _isScrolled = true;
      });
    }
    else if(_scrollController.offset <= offset && _isScrolled){
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 20,
        actions: _appBarWidgets(),
        backgroundColor: _isScrolled ? Colors.black.withAlpha(220) : Colors.transparent,
        elevation: 1,
        shadowColor: _isScrolled ? Colors.black : Colors.transparent,
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

                child: CustomScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  slivers: [
                    //? Espaciado
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100)
                    ),
                    //? Lista como tal
                    SliverList(
                      delegate: 
                        SliverChildBuilderDelegate((context, index) {
                          final musica = widget.listado[index];
                          return MusicItem(music: musica);
                        },
                      childCount: widget.listado.length
                      )
                    ),
                  ]
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}