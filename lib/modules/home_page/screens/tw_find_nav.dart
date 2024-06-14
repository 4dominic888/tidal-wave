import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/text_field_find.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';
import 'package:tidal_wave/services/repositories/tw_music_repository.dart';
import 'package:tidal_wave/shared/music_state_util.dart';

class TwFindNav extends StatefulWidget {
  const TwFindNav({super.key});

  @override
  State<TwFindNav> createState() => _TwFindNavState();
}

class _TwFindNavState extends State<TwFindNav> {

  String? selectUUID;

  void _findMusic(String query){
    setState(() {
      // _list = widget.listado.where((element) {
      //   if (value.trim().isEmpty) {
      //     return true;
      //   }
      //   return element.titulo.toLowerCase().contains(value.toLowerCase().trim()) ||
      //         element.artistasStr.toLowerCase().contains(value.toLowerCase().trim());

      // }).toList();      
    });
  }

  Future<List<Music>> listOfMusic() async {
    final result = await TWMusicRepository().getAll();
    if(result.onSuccess){return result.data!.toList();}
    throw Exception(result.errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          actions: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFieldFind(
                  hintText:'Buscar cancion...',
                  suffixIcon: IconButtonUIMusic(
                    borderColor: Colors.blue.shade400.withAlpha(50),
                    borderSize: 2.0,
                    fillColor: Colors.transparent,
                    icon: const Icon(Icons.search, size: 25, color: Colors.white),
                    onTap: () {},
                  ),
                  onChanged: _findMusic
                ),
              )
            ),
          ],
        ),
    
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
    
        FutureBuilder<List<Music>>(
          future: listOfMusic(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));}
            if(snapshot.hasError) {return SliverToBoxAdapter(child: Center(child: Text('Ha ocurrido un error ${snapshot.error.toString()}', style: const TextStyle(color: Colors.white))));}
            return StatefulBuilder(
              builder: (context, setState) {
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1
                  ),
                  delegate: SliverChildBuilderDelegate(childCount: snapshot.data!.length, (context, index) {
                    final item = snapshot.data![index];
                    return Builder(
                      builder: (context) {
                        return MusicElementView(
                          item: item,
                          selected: [item.uuid == selectUUID],
                          onPlay: () {
                            selectUUID = item.uuid;
                            setState(() {});
                          },
                        );
                      }
                    );
                  }),
                );
              }
            );
          }
        )
      ],
    );
  }
}

class MusicElementView extends StatelessWidget {

  final Music item;
  final List<bool>? selected;
  final void Function()? onPlay;

  const MusicElementView({super.key, required this.item, this.onPlay, this.selected = const [false]});

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Ink.image(
            image: NetworkImage(item.imagen.toString()),
            child: InkWell(
              onTap: () => print(item.uuid),
            ),
          ),
          Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: StreamBuilder<PlayerState>(
                      stream: context.read<MusicCubit>().state.playerStateStream.asBroadcastStream(),
                      builder: (context, snapshot) {
                        return IconButtonUIMusic(
                          borderColor: selected!.first && snapshot.data?.processingState == ProcessingState.loading ? Colors.yellowAccent.withOpacity(0.6) : Colors.transparent,
                          borderSize: 3.0,
                          fillColor: Colors.grey.shade700.withOpacity(0.6),
                          icon: selected!.first ? 
                            snapshot.data?.processingState == ProcessingState.loading ? const Icon(Icons.watch_later, color: Colors.white) : MusicStateUtil.playIcon(snapshot.data, color: Colors.white) :
                            const Icon(Icons.play_arrow_rounded, color: Colors.white),
                          onTap: selected!.first ? MusicStateUtil.playReturns(snapshot.data,
                            playCase: context.read<MusicCubit>().state.play,
                            stopCase: context.read<MusicCubit>().state.pause,
                            playStatic: () async{
                              await context.read<MusicCubit>().setClip(item.musica.toString(), item.betterMoment);
                              if(!context.mounted) return;
                              await context.read<MusicCubit>().state.play();                              
                            },
                          ) : 
                          () async {
                              onPlay?.call();
                              await context.read<MusicCubit>().setClip(item.musica.toString(), item.betterMoment);
                              if(!context.mounted) return;
                              await context.read<MusicCubit>().state.play();
                            },
                        );
                      }
                    ),
                  ),
                  StreamBuilder<Duration>(
                    stream: context.read<MusicCubit>().state.positionStream.asBroadcastStream(),
                    builder: (context, snapshot) {
                      return selected!.first && context.read<MusicCubit>().state.playerState.processingState != ProcessingState.completed ? 
                      LinearProgressIndicator(
                        value: (snapshot.data?.inMilliseconds ?? 0) / (context.read<MusicCubit>().state.duration?.inMilliseconds ?? 1),
                        color: Colors.blueAccent,
                      ) : const SizedBox.shrink();
                    }
                  ),
                ],
              ),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    color: Colors.grey.shade700.withOpacity(0.8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                          title: Text(item.titulo,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          subtitle: Text('por ${item.artistasStr}',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  )
                )
              ),
            ],
          )
        ],
      ),
    );
  }
}