import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/mini_music_player.dart';
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
  bool _isPlay = false;

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
        toolbarHeight: 80,
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
        
        child: Column(
          children: [
            Expanded(
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
                          //? Espaciado, tal vez se coloque algun disen~o, para los albunes o historial
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100)
                          ),

                          //? Lista como tal
                          SliverList(
                            delegate: 
                              SliverChildBuilderDelegate((context, index) {
                                final musica = widget.listado[index];

                                //TODO: Agregar funcionalidad de play y opciones, play debe mostrar el mini reproductor de abajo
                                return MusicItem(
                                  music: musica,
                                  onPlay: () async {
                                    setState(() {
                                      _isPlay = true;
                                    });
                                    context.read<MusicCubit>().setMusic(musica.toAudioSource('0'));                                 
                                  },
                                  onOptions: (){}
                                );
                              },
                            childCount: widget.listado.length
                            )
                          ),
                        ],                  
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInBack,
                    bottom: _isPlay ? 0 : -90,
                    width: MediaQuery.of(context).size.width,
                    height: 90,
                    child: const MiniMusicPlayer()
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}