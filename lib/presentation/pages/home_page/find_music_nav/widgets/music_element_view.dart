// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/data/abstractions/save_file_local.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_list_manager_use_case.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/download_music_cubit.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/presentation/pages/reproductor_musica/screens/reproductor_musica_screen.dart';
import 'package:tidal_wave/presentation/utils/function_utils.dart';
import 'package:tidal_wave/presentation/utils/music_state_util.dart';
import 'package:tidal_wave/presentation/utils/snackbar_util.dart';

final _musicListManagerUseCase = GetIt.I<MusicListManagerUseCase>();
final _musicManagerUseCase = GetIt.I<MusicManagerUseCase>();
final _downloadMusicCubit = GetIt.I<DownloadMusicCubit>();

class MusicElementView extends StatefulWidget {

  final Music item;
  final bool? isOnline;

  const MusicElementView({super.key, required this.item, this.isOnline = true});

  @override
  State<MusicElementView> createState() => _MusicElementViewState();
}

class _MusicElementViewState extends State<MusicElementView> {
  Future<void> _showAddMusicToList(BuildContext context, Music music, MusicList listSelected) async {
    Result<String>? result;
    await showLoadingDialog(context,  () async { 
      result = await _musicListManagerUseCase.agregarMusicaALista(
        musicId: music.uuid!,
        listId: listSelected.id,
      );
    }, message: 'Cargando musica a la lista');
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
    setState(() => _downloadMusicCubit.addDownloadElement(idMusic));
    _musicManagerUseCase.descargarMusica(
      idMusic,
      progressOfDownload: (data) => _downloadMusicCubit.addProgressOfDownload(idMusic, data)
    ).then((downloadResult) async {
      if(!downloadResult.onSuccess){
        await _downloadMusicCubit.closeStreamController(idMusic);
        _downloadMusicCubit.removeDownloadElement(idMusic);
        SnackbarUtil.failureSnack(context, message: 'Error', details: downloadResult.errorMessage!);
        setState(() {});
        return;
      }
      SnackbarUtil.successSnack(context, message: downloadResult.data!);
      await _downloadMusicCubit.closeStreamController(idMusic);
      _downloadMusicCubit.removeDownloadElement(idMusic);
      setState(() {});
    });
  }

  Future<void> _viewMoreMusicInfo(BuildContext contextBottomSheet) => showModalBottomSheet(context: contextBottomSheet, 
    backgroundColor: Colors.grey.shade800, builder: (contextBottomSheet) => SizedBox(
      height: 200,
      child: Stack(
        children: [
          //* Imagen de fondo
          widget.item.imagen != null ? 
          getWidgetImage(
            widget.item.imagen!,
            width: MediaQuery.of(contextBottomSheet).size.width,
            fit: BoxFit.cover,
            isOnline: widget.isOnline
          ) : Image.asset('assets/placeholder/music-placeholder.png', 
            width: MediaQuery.of(contextBottomSheet).size.width,
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
                SingleChildScrollView(scrollDirection: Axis.horizontal ,child: Text(widget.item.titulo, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                SingleChildScrollView(scrollDirection: Axis.horizontal ,child: Text(widget.item.artistasStr, style: const TextStyle(fontSize: 15))),
                const SizedBox(height: 10),
                Expanded(
                  child: widget.item.type == DataSourceType.online ? _rowInfoOnline(contextBottomSheet) : _rowInfoDownloaded(context),
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
          onPressed: () async => _showListOfMusics(context, widget.item),
          style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey.shade900)),
          child: const Text('Agregar a lista')
        ),
        const Spacer(),  
      ],
    );
  }

  StatefulBuilder _rowInfoOnline(BuildContext context) {
    return StatefulBuilder(
      builder: (stfContext, setState) {
        return FutureBuilder<bool>(
          future: _musicManagerUseCase.musicaExistente(widget.item.uuid!),
          builder: (stfContext, snapshot) {
            late final List<Widget> rowList;
            if(snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
            
            if(!snapshot.data!) { //* Si la musica no esta entre las descargadas
              rowList = [
              //* Si no se esta descargando este elemento, osea no esta en las descargas

              _downloadMusicCubit.existDownloadElement(widget.item.uuid!) ?
                StreamBuilder<ProgressOfDownloadData>(
                  stream: _downloadMusicCubit.getStream(widget.item.uuid!),
                  builder: (context, downloadSnapshot) {
                    final String downloadedKB = (((downloadSnapshot.data?.downloaded) ?? 0) / 1048576).toStringAsFixed(2);
                    final String totalKB = (((downloadSnapshot.data?.total) ?? 0) / 1048576).toStringAsFixed(2);
                    final String progressPercent = ((downloadSnapshot.data?.progress) ?? 0).toStringAsFixed(2);
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LinearProgressIndicator(
                            value: ((downloadSnapshot.data?.progress) ?? 0) / 100,
                            color: Colors.blueAccent,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$downloadedKB MB / $totalKB MB',),
                              Text('$progressPercent%')
                            ],
                          )
                        ],
                      ),
                    );
                }) : 
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _downloadMusic(this.context, widget.item.uuid!);
                      setState((){});
                    },
                    style: ButtonStyle(backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey.shade900)),
                    child: const Text('Descargar'),
                  )
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
            child: Text(widget.item.uuid!, 
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 8,
                shadows: [Shadow(offset: Offset(2, 2), blurRadius: 10)]
              ),
              textAlign: TextAlign.center
            ),
          ),

          Ink.image(
            image: widget.item.imagen != null ? 
            getImage(widget.item.imagen!, isOnline: widget.isOnline) : 
            Image.asset('assets/placeholder/music-placeholder.png').image,
            child: InkWell(
              onTap: (){
                if(context.read<MusicCubit>().state.audioSource != null && context.read<MusicCubit>().idSelected == (widget.item.uuid ?? '')){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReproductorMusicaScreen()));
                }
              }
            ),
          ),

          Column(
            children: [
              Column(
                children: [

                  //* Boton de reproduccion de musica
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: StreamBuilder<PlayerState>( //* Para poder actualizar los botones correctamente segun el estado de la musica
                      stream: context.read<MusicCubit>().state.playerStateStream.asBroadcastStream(),
                      builder: (context, snapshot) {
                        return StreamBuilder<Duration>( //* Actualizar la barra de progreso circular segun el progreso de la musica
                          stream: context.read<MusicCubit>().state.positionStream.asBroadcastStream(),
                          builder: (context, snapshotDuration) {
                            return IconButtonUIMusic(
                              borderColor: context.read<MusicCubit>().idSelected == (widget.item.uuid ?? '') && snapshot.data?.processingState == ProcessingState.loading ? Colors.yellowAccent.withOpacity(0.6) : Colors.transparent,
                              borderSize: 3.0,
                              progress: 
                                //* Si esta seleccionado y se esta escuchando
                                context.read<MusicCubit>().idSelected == (widget.item.uuid ?? '') && context.read<MusicCubit>().state.playerState.processingState != ProcessingState.completed ? 
                                (snapshotDuration.data?.inMilliseconds ?? 0) / (context.read<MusicCubit>().state.duration?.inMilliseconds ?? 1) : 0.0,
                              fillColor: Colors.grey.shade700.withOpacity(0.6),
                              icon: context.read<MusicCubit>().idSelected == (widget.item.uuid ?? '') ? 
                                snapshot.data?.processingState == ProcessingState.loading ? const Icon(Icons.watch_later) : MusicStateUtil.playIcon(snapshot.data) :
                                const Icon(Icons.play_arrow_rounded),
                            
                              onTap: context.read<MusicCubit>().idSelected == (widget.item.uuid ?? '') ? 
                              MusicStateUtil.playReturns(
                                snapshot.data,
                                playCase: () {
                                  context.read<MusicCubit>().setSelectedId(widget.item.uuid!);
                                  context.read<MusicCubit>().state.play();
                                },
                                stopCase: context.read<MusicCubit>().state.pause,
                                playStatic: () async{
                                  context.read<MusicCubit>().setSelectedId(widget.item.uuid!);
                                  await context.read<MusicCubit>().setMusic(widget.item);
                                  if(!context.mounted) return;
                                  await context.read<MusicCubit>().state.play();
                                  if(!context.mounted) return;
                                  context.read<MusicCubit>().isActive;
                                },
                              ) : 
                              () async {
                                  context.read<MusicCubit>().setSelectedId(widget.item.uuid!);
                                  await context.read<MusicCubit>().setMusic(widget.item);
                                  if(!context.mounted) return;
                                  await context.read<MusicCubit>().state.play();
                                  if(!context.mounted) return;
                                  context.read<MusicCubit>().isActive;
                                },
                            );
                          }
                        );
                      }
                    ),
                  ),

                  if(_downloadMusicCubit.existDownloadElement(widget.item.uuid!))
                  StreamBuilder<ProgressOfDownloadData>(
                    stream: _downloadMusicCubit.getStream(widget.item.uuid!),
                    builder: (context, snapshot) { 
                      //* Barra de progreso para la descarga
                      return LinearProgressIndicator(
                          value: snapshot.data != null ? (snapshot.data!.progress / 100) : 0,
                          color: Colors.blueAccent
                      );
                    }
                  )
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
                              title: Text(widget.item.titulo,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('por ${widget.item.artistasStr}',
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