import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/presentation/bloc/music_playing_cubit.dart';
import 'package:tidal_wave/presentation/bloc/play_list_state_cubit.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/mini_music_player.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/music_item.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/text_field_find.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/title_container.dart';
import 'package:tidal_wave/domain/models/music.dart';
class ListaMusicaScreen extends StatefulWidget {

  final MusicList musicList;

  const ListaMusicaScreen({super.key, required this.musicList});

  @override
  State<ListaMusicaScreen> createState() => _ListaMusicaScreenState();
}

class _ListaMusicaScreenState extends State<ListaMusicaScreen> {

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool firstPlayed = false;

  late List<Music> _list;

  final _playListStateCubit = GetIt.I<PlayListStateCubit>();

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
            icon: const Icon(Icons.search, size: 25),
            onTap: () {},
          ),
          onChanged: (value) {
            setState(() {
              if(widget.musicList.musics == null) return;
              _list = widget.musicList.musics!.where((element) {
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
    
    final int musicLenght = widget.musicList.musics != null ? widget.musicList.musics!.length : 0;

    if(musicLenght > 0){
      for (int i = 0; i < musicLenght; i++) {
        widget.musicList.musics![i].index = i;
      }
    }
    _list = widget.musicList.musics ?? [];
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
                                final String text = (mediaData != null) && context.read<MusicPlayingCubit>().isActive ? 'Escuchando ${mediaData.title}' : 'En silencio...';
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
                                  return BlocBuilder<PlayListStateCubit, Map<String, int>>(
                                    bloc: _playListStateCubit,
                                    builder: (context, state) {
                                      return MusicItem(
                                        selected: state[widget.musicList.id] == index,
                                        music: musica,
                                        onPlay: () async {
                                          _playListStateCubit.playingMusicOnAList(listId: widget.musicList.id, index: index);
                                          if(!firstPlayed){
                                            firstPlayed = true;
                                            await context.read<MusicCubit>().setPlayList(widget.musicList.musics ?? []);
                                          }
                                          if (!context.read<MusicPlayingCubit>().isActive) {
                                            setState(() => context.read<MusicPlayingCubit>().active); 
                                          }
                                          await context.read<MusicCubit>().seekTo(index);
                                        },
                                        onOptions: (){
                                          //* Codigo por si se desea hacer algo al abrir el menu desplegable de cada cancion
                                        }
                                      );
                                    }
                                  );
                                }
                              )
                            );
                          }
                        ) else const SliverToBoxAdapter(child: Center(child: Text('Sin musica'))),
                        
                        //? En caso el mini reproductor de musica no este activo
                        if(GetIt.I<MusicPlayingCubit>().isActive) const SliverToBoxAdapter(
                          child: SizedBox(height: 110)
                        ),
                      ],                  
                    ),
                  ),
                  
                  //? Mini music player
                  BlocBuilder<MusicPlayingCubit, bool>(
                    bloc: GetIt.I<MusicPlayingCubit>(),
                    builder: (context, state) {
                      return AnimatedPositioned(
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInBack,
                        bottom: state ? 0 : -90,
                        width: MediaQuery.of(context).size.width,
                        height: 90,
                        child: const MiniMusicPlayer()
                      );
                    }
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
