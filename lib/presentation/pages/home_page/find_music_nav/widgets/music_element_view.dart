import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_list_manager_use_case.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/presentation/pages/reproductor_musica/screens/reproductor_musica_screen.dart';
import 'package:tidal_wave/presentation/utils/function_utils.dart';
import 'package:tidal_wave/presentation/utils/music_state_util.dart';

final _musicListManagerUseCase = GetIt.I<MusicListManagerUseCase>();
final _musicManagerUseCase = GetIt.I<MusicManagerUseCase>();

class MusicElementView extends StatelessWidget {

  final Music item;
  final List<bool>? selected;
  final void Function()? onPlay;
  final bool? isOnline;

  const MusicElementView({super.key, required this.item, this.onPlay, this.isOnline = true, this.selected = const [false]});

  Future<void> _showAddMusicToList(BuildContext context, Music music, MusicList listSelected) async {
    Result<String>? result;
    await showLoadingDialog(context,  () async { 
      result = await _musicListManagerUseCase.agregarMusicaALista(
        musicId: music.uuid!,
        listId: listSelected.id,
      );
    }, message: 'Cargando cancion a la lista');
    if(!context.mounted) return;

    if(!result!.onSuccess){
      showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: result!.errorMessage!));
    }
    else{
      showDialog(context: context, builder: (context) => PopupMessage(title: 'Exito', description: 'Se agrego correctamente la musica a la lista', onClose: () {
        Navigator.of(context).pop();
      }));
    }
  }

  Future<void> _showListOfMusics(BuildContext context, Music music) async {
    late Result<List<MusicList>> listResult;
    await showLoadingDialog(context, () async => listResult = await _musicListManagerUseCase.obtenerListasLocales());
    if(!context.mounted) return;
    if(!listResult.onSuccess) {
      showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: listResult.errorMessage!));
      return;
    }
    final List<MusicList> listas = listResult.data!;
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Elige una lista'),
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
                    onTap: () async => await _showAddMusicToList(context, music, list)
                  )).toList(),
                ),
              ),
            ],
          );
        }
      ),
    ));
  }

  Future<void> _downloadMusic(BuildContext context, String idMusic) async{
    late final Result<String> downloadResult;
    await showLoadingDialog(context, () async => downloadResult = await _musicManagerUseCase.descargarMusica(idMusic, 
      progressOfDownload: (total, downloaded, progress) {
        print('$downloaded/$total $progress%');
      })
    );
    if(!context.mounted) return;
    if(!downloadResult.onSuccess){
      showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: downloadResult.errorMessage!));
      return;
    }
    showDialog(context: context, builder: (context) => PopupMessage(title: 'Exito', description: downloadResult.data!));
  }

  Future<void> _viewMoreMusicInfo(BuildContext context) => showModalBottomSheet(context: context, 
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
                  child: item.type == DataSourceType.online ? _rowInfoOnline() : _rowInfoDownloaded(context),
                ),
              ],
            ),
          )
        ],
      )
    )
  );

  Row _rowInfoDownloaded(BuildContext context){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () async => _showListOfMusics(context, item),
          style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey.shade900)),
          child: const Text('Agregar a lista')
        ),
        const Spacer(),  
      ],
    );
  }

  FutureBuilder<bool> _rowInfoOnline() {
    return FutureBuilder(
      future: _musicManagerUseCase.musicaExistente(item.uuid!),
      builder: (context, snapshot) {
        late final List<Widget> rowList;
        if(snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
        if(!snapshot.data!) {
          rowList = [
            // ElevatedButton(
            //   onPressed: () async => _showListOfMusics(context, item),
            //   style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey.shade900)),
            //   child: const Text('Agregar a lista')
            // ),
            Expanded(
              child: ElevatedButton(
                onPressed: () async => await _downloadMusic(context, item.uuid!),
                style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey.shade900)),
                child: const Text('Descargar')
              ),
            )
          ];
        }
        else{
          rowList = [
            ElevatedButton(
              onPressed: null,
              style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey.shade600)),
              child: const Text('Obtenido')
            ),
          ];
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rowList,
        );
      }
    );
  }

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
          //? Para hacer pruebas
          //TODO: Luego se quita
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(item.uuid!, 
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 8,
                shadows: [Shadow(offset: Offset(2, 2), blurRadius: 10)]
              ),
              textAlign: TextAlign.center
            ),
          ),

          Ink.image(
            image: item.imagen != null ? 
            getImage(item.imagen!, isOnline: isOnline) : 
            Image.asset('assets/placeholder/music-placeholder.png').image,
            child: InkWell(
              onTap: (){
                if(context.read<MusicCubit>().state.playing && selected!.first){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReproductorMusicaScreen()));
                }
              }
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
                              await context.read<MusicCubit>().setMusic(item);
                              if(!context.mounted) return;
                              await context.read<MusicCubit>().state.play();
                              if(!context.mounted) return;
                              context.read<MusicCubit>().isActive;
                            },
                          ) : 
                          () async {
                              onPlay?.call();
                              await context.read<MusicCubit>().setMusic(item);
                              if(!context.mounted) return;
                              await context.read<MusicCubit>().state.play();
                              context.read<MusicCubit>().isActive;
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
                  child: Ink(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.white,
                      onTap: () => _viewMoreMusicInfo(context),                      
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
                      ),
                    ),
                  )
                )
              )


            ],
          )
        ],
      ),
    );
  }
}