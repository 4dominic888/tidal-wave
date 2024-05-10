import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/bloc/play_list_cubit.dart';
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
  late List<Music> _list;

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
          onChanged: (value) {
            setState(() {
              _list = widget.listado.where((element) {
                if (value.trim().isEmpty) {
                  return true;
                }
                return element.titulo.toLowerCase().contains(value.toLowerCase().trim()) ||
                      element.artista.toLowerCase().contains(value.toLowerCase().trim());

              }).toList();              
            });

          },
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
    //* El codigo ilegible asdasfasfas
    context.read<MusicCubit>().setPlayList(context.read<PlayListCubit>().setPlayList(widget.listado));
    _list = widget.listado;
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

        //? Degradado
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

                          const SliverToBoxAdapter(child: SizedBox(height: 110)),

                          //? Escuchando...
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 110,
                              child: StreamBuilder<SequenceState?>(
                                stream: context.read<MusicCubit>().state.sequenceStateStream,
                                builder: (context, snapshot) {
                                  final mediaData = snapshot.data?.currentSource?.tag as MediaItem?;
                                  final String text = (mediaData != null) && _isPlay ? 'Escuchando ${mediaData.title}' : 'En silencio...';
                                  return Container(
                                    height: 140,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Colors.black.withOpacity(0.2),Colors.white.withOpacity(0.2)]
                                      )
                                    ),
                                    child: Column(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top: 5, bottom: 5),
                                          child: Icon(Icons.multitrack_audio_sharp, size: 40, color: Colors.white),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 40, left: 40, top: 8),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(text,
                                              style: const TextStyle(color: Colors.white, fontSize: 20),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }
                              ),
                            )
                          ),

                          //? Lista como tal
                          _list.isNotEmpty ? 
                          StreamBuilder<SequenceState?>(
                            stream: context.read<MusicCubit>().state.sequenceStateStream,
                            builder: (context, snapshot) {
                              return SliverList( 
                                delegate: 
                                  SliverChildBuilderDelegate((context, index) {
                                    final musica = _list[index];
                                    return MusicItem(
                                      selected: [musica.index == (_isPlay ? snapshot.data?.currentIndex : -1)],
                                      music: musica,
                                      onPlay: () async {
                                        setState(() {
                                          _isPlay = true;
                                        });
                                        context.read<MusicCubit>().seekTo(musica.index);
                                      },
                                      onOptions: (){
                                        //* Codigo por si se desea hacer algo al abrir el menu desplegable de cada cancion
                                      }
                                    );
                                  },
                                childCount: _list.length
                              )
                              );
                            }
                          ) : 
                          const SliverToBoxAdapter(child: Center(child: Text('Sin musica', style: TextStyle(color: Colors.white)))),
                          
                          if(_isPlay) const SliverToBoxAdapter(
                            child: SizedBox(height: 110)
                          ),
                        ],                  
                      ),
                    ),
                  ),
                  
                  //? Mini music player
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