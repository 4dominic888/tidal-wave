import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/bloc/play_list_cubit.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/mini_music_player.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/music_item.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/text_field_find.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/title_container.dart';
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
  late List<Music> _list;

  List<Widget> _appBarWidgets(){
    return [      
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
                      element.artistasStr.toLowerCase().contains(value.toLowerCase().trim());

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
        automaticallyImplyLeading: false,
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
                  SizedBox(
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
                            height: 120,
                            child: StreamBuilder<SequenceState?>(
                              stream: context.read<MusicCubit>().state.sequenceStateStream.asBroadcastStream(),
                              builder: (context, snapshot) {
                                final mediaData = snapshot.data?.currentSource?.tag as MediaItem?;
                                final String text = (mediaData != null) && context.read<MusicCubit>().isActive ? 'Escuchando ${mediaData.title}' : 'En silencio...';
                                return TitleContainer(text: text);
                              }
                            ),
                          )
                        ),

                        //? Lista como tal
                        if (_list.isNotEmpty) StreamBuilder<int?>(
                          stream: context.read<MusicCubit>().state.currentIndexStream.asBroadcastStream(),
                          builder: (context, snapshot) {
                            return SliverList( 
                              delegate: 
                                SliverChildBuilderDelegate(childCount: _list.length, (context, index) {
                                  final musica = _list[index];
                                  return MusicItem(
                                    selected: [musica.index == (context.read<MusicCubit>().isActive ? _list[snapshot.data ?? 0].index : -1)],
                                    music: musica,
                                    onPlay: () async {
                                      if (!context.read<MusicCubit>().isActive) {
                                        setState(() => context.read<MusicCubit>().isActive = true); 
                                      }
                                      context.read<MusicCubit>().seekTo(musica.index);
                                    },
                                    onOptions: (){
                                      //* Codigo por si se desea hacer algo al abrir el menu desplegable de cada cancion
                                    }
                                  );
                                }
                              )
                            );
                          }
                        ) else const SliverToBoxAdapter(child: Center(child: Text('Sin musica', style: TextStyle(color: Colors.white)))),
                        
                        //? En caso el mini reproductor de musica no este activo
                        if(context.read<MusicCubit>().isActive) const SliverToBoxAdapter(
                          child: SizedBox(height: 110)
                        ),
                      ],                  
                    ),
                  ),
                  
                  //? Mini music player
                  AnimatedPositioned(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInBack,
                    bottom: context.read<MusicCubit>().isActive ? 0 : -90,
                    width: MediaQuery.of(context).size.width,
                    height: 90,
                    child: MiniMusicPlayer(externalSetState: () => setState(() {}))
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
