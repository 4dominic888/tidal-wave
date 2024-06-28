import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_list_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/presentation/utils/function_utils.dart';
import 'package:tidal_wave/presentation/utils/music_state_util.dart';

final _musicListManagerUseCase = GetIt.I<MusicListManagerUseCase>();

class MusicElementView extends StatelessWidget {

  final Music item;
  final List<bool>? selected;
  final void Function()? onPlay;
  final bool? isOnline;

  const MusicElementView({super.key, required this.item, this.onPlay, this.isOnline = true, this.selected = const [false]});

  Future<void> showAddMusicToList(BuildContext context, Music music, MusicList listSelected) async {
    late Result<String> result;
    showLoadingDialog(context,  () async { 
      await context.read<MusicCubit>().preLoadMusic(music);
      result = await _musicListManagerUseCase.agregarMusicaALista(
        musicId: music.uuid!,
        listId: listSelected.id,
      );
    }, message: 'Cargando cancion a la lista');

    if(!result.onSuccess){
      showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: result.errorMessage!));
    }
    else{
      showDialog(context: context, builder: (context) => PopupMessage(title: 'Exito', description: 'Se agrego correctamente la musica a la lista', onClose: () {
        Navigator.of(context).pop();
      }));
    }
  }

  Future<void> showListOfMusics(BuildContext context, Music music) async {
    late Result<List<MusicList>> listResult;
    await showLoadingDialog(context, () async => listResult = await _musicListManagerUseCase.obtenerListasLocales());
    if(!listResult.onSuccess) {
      PopupDialog(title: 'Error', description: listResult.errorMessage!);
      return;
    }
    final List<MusicList> listas = listResult.data!;
    if(!context.mounted) return;
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Elige una lista'),
      backgroundColor: Colors.grey.shade900,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: listas.map((list) => 
                  ListTile(
                    title: Text(list.name),
                    onTap: () async => await showAddMusicToList(context, music, list)
                  )).toList(),
                ),
              ),
            ],
          );
        }
      ),
    ));
  }

  Future<void> viewMoreMusicInfo(BuildContext context) => showModalBottomSheet(context: context, 
    backgroundColor: Colors.grey.shade800, builder: (context) => SizedBox(
      height: 200,
      child: Stack(
        children: [
          //* Imagen de fondo
          item.imagen != null ? 
          getWidgetImage(
            item.imagen!,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            isOnline: isOnline
          ) : Image.asset('assets/placeholder/music-placeholder.png', 
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),

          //* Efecto de desenfoque
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.grey.shade900.withOpacity(0.7)),
          ),


          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(scrollDirection: Axis.horizontal ,child: Text(item.titulo, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                SingleChildScrollView(scrollDirection: Axis.horizontal ,child: Text(item.artistasStr, style: const TextStyle(fontSize: 15))),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () async => showListOfMusics(context, item),
                        style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey.shade900)),
                        child: const Text('Agregar a lista')
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          await showLoadingDialog(context, () async => await Future.delayed(const Duration(seconds: 5)));
                        },
                        style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey.shade900)),
                        child: const Text('Descargar')
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      )
    )
  );

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
            image: item.imagen != null ? 
            getImage(item.imagen!, isOnline: isOnline) : 
            Image.asset('assets/placeholder/music-placeholder.png').image,
            child: InkWell(
              onTap: () => viewMoreMusicInfo(context),
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
                            snapshot.data?.processingState == ProcessingState.loading ? const Icon(Icons.watch_later) : MusicStateUtil.playIcon(snapshot.data) :
                            const Icon(Icons.play_arrow_rounded),

                          onTap: selected!.first ? MusicStateUtil.playReturns(snapshot.data,
                            playCase: context.read<MusicCubit>().state.play,
                            stopCase: context.read<MusicCubit>().state.pause,
                            playStatic: () async{
                              await context.read<MusicCubit>().setClip(item.toAudioSource('0'), item.betterMoment);
                              if(!context.mounted) return;
                              await context.read<MusicCubit>().state.play();                              
                            },
                          ) : 
                          () async {
                              onPlay?.call();
                              await context.read<MusicCubit>().setClip(item.toAudioSource('0'), item.betterMoment);
                              if(!context.mounted) return;
                              await context.read<MusicCubit>().state.play();
                            },
                        );
                      }
                    ),
                  ),

                  //* Barra de progreso
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

              //* Metadata
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('por ${item.artistasStr}',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
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