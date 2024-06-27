import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/presentation/pages/subir_musica/widgets/duration_form_field.dart';
import 'package:tidal_wave/presentation/controllers/tw_select_file_controller.dart';
import 'package:tidal_wave/presentation/utils/music_state_util.dart';
import 'package:tidal_wave/presentation/utils/function_utils.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_select_file.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_text_field.dart';

class UploadMusicScreen extends StatefulWidget {
  const UploadMusicScreen({super.key});

  @override
  State<UploadMusicScreen> createState() => _UploadMusicScreenState();
}

class _UploadMusicScreenState extends State<UploadMusicScreen> {

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _bestDurationController = TextEditingController();
  final _musicController = TWSelectFileController();
  final _imageController = TWSelectFileController();
  final _btnController = RoundedLoadingButtonController();


  final _musicFileUploadStreamController = StreamController<double>();
  final _imageFileUploadStreamController = StreamController<double>();

  final _musicManagerUseCase = GetIt.I<MusicManagerUseCase>();

  void onSubmit() async {
    if(_formKey.currentState!.validate()){
      final bool hasImage = _imageController.value != null;

      Music music = Music(
        titulo: _titleController.text,
        artistas: [_artistController.text],
        type: DataSourceType.online,
        musica: Uri.parse(_musicController.value!.path),
        imagen: hasImage ? Uri.parse(_imageController.value!.path) : null,
        duration: _musicController.musicDuration!,
        stars: 0,
        uploadAt: Timestamp.now(),
        betterMoment: _musicController.clipMoment ?? Duration.zero
      );

      final result = await _musicManagerUseCase.subirMusicaOnline(music,
        onLoadImagen: (value) {
          _imageFileUploadStreamController.sink.add(
            value.bytesTransferred / value.totalBytes
          );
        },
        onLoadMusic: (value){
        _musicFileUploadStreamController.sink.add(
          value.bytesTransferred / value.totalBytes
        );          
        }
      );

      if(!mounted) return;

      if(!result.onSuccess){
        showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: result.errorMessage!));
      }
      showDialog(context: context, builder: (context) => PopupMessage(title: 'Exito', description: result.data!));
      _btnController.success();
      return;
    }
    _btnController.error();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          
                //* Titulo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TWTextField(
                    controller: _titleController,
                    hintText: 'Titulo',
                    textInputType: TextInputType.emailAddress,
                    icon: const Icon(Icons.text_fields_rounded),
                    validator: (value) {
                      if(value == null || value.trim().isEmpty) {return "Campo no proporcionado";}
                      if(value.length <= 2 || value.length > 50) {return "El campo debe ser mayor a 2 y menor a 50 caracteres";}
                      return null;
                    },
                  ),
                ),
          
                //* Artista
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TWTextField(
                    controller: _artistController,
                    hintText: 'Artista',
                    textInputType: TextInputType.emailAddress,
                    icon: const Icon(Icons.person_2_sharp),
                    validator: (value) {
                      if(value == null || value.trim().isEmpty) {return "Campo no proporcionado";}
                      if(value.length <= 2 || value.length > 50) {return "El campo debe ser mayor a 2 y menor a 50 caracteres";}
                      return null;
                    },
                  ),
                ),
                
                //* Musica file
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TWSelectFile(
                    controller: _musicController,
                    loadStreamController: _musicFileUploadStreamController,
                    labelText: 'Musica',
                    message: 'Selecciona el archivo de musica',
                    fileType: FileType.audio,
                    megaBytesLimit: 20,
                    validator: (_) {
                      if(_musicController.value == null) {return "Archivo no proporcionado";}
                      return null;
                    },
                    onChanged: () => setState(() {
                      _musicController.clipMoment = Duration.zero;
                      _bestDurationController.text = "";
                      context.read<MusicCubit>().setClip(AudioSource.file(_musicController.value!.path), _musicController.clipMoment ?? Duration.zero);
                      context.read<MusicCubit>().state.pause();
                    })
                    ,
                  )
                ),
                //* Duration music to present
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Builder(
                    builder: (context) {
                      return Row(
                        children: [
                          Expanded(child: Column(
                            children: [
                              const Text('Momento destacado:'),
                              const Text('Durara 5 segundos segun el tiempo establecido', style: TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
                              if(_musicController.value != null)
                                StreamBuilder<PlayerState>(
                                  stream: context.read<MusicCubit>().state.playerStateStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.data?.processingState == ProcessingState.completed) {
                                      context.read<MusicCubit>().setClip(AudioSource.file(_musicController.value!.path), _musicController.clipMoment ?? Duration.zero);
                                      context.read<MusicCubit>().state.pause();
                                    }
                                    return IconButton(
                                      onPressed: MusicStateUtil.playReturns<void Function()>(snapshot.data,
                                        playCase: context.read<MusicCubit>().state.play,
                                        stopCase: context.read<MusicCubit>().state.pause,
                                        playStatic: context.read<MusicCubit>().state.play,
                                      ),
                                      icon: MusicStateUtil.playIcon(snapshot.data)
                                    );
                                  },
                                ),
                              if(_musicController.value != null)
                                StreamBuilder<Duration>(
                                  stream: context.read<MusicCubit>().state.positionStream.asBroadcastStream(),
                                  builder: (context, snapshot) {
                                    return LinearProgressIndicator(
                                      value: (snapshot.data?.inMilliseconds ?? 0) / (context.read<MusicCubit>().state.duration?.inMilliseconds ?? 1),
                                      color: Colors.blueAccent,
                                    );
                                  }
                                )
                            ],
                          )),
                          const SizedBox(width: 10),
                          DurationFormField(
                            topText: _musicController.musicDuration != null ? Text('Max: ${toStringDurationFormat(_musicController.musicDuration! - const Duration(seconds: 5))}', style: const TextStyle(color: Colors.grey)) : null,
                            controller: _bestDurationController,
                            enabled: _musicController.value != null,
                            maxDuration: _musicController.musicDuration != null ? _musicController.musicDuration! - Duration.zero : null,
                            onChanged: (value) {
                              _musicController.clipMoment = parseDuration(value);
                              if(_musicController.clipMoment! > _musicController.musicDuration! - const Duration(seconds: 5)) {_musicController.clipMoment = _musicController.musicDuration! - const Duration(seconds: 5);}
                              _bestDurationController.text = _musicController.clipMoment != Duration.zero ? toStringDurationFormat(_musicController.clipMoment!) : "";
                            },
                            validator: (value) {
                              if(_musicController.value == null) {return 'Musica no seleccionada';}
                              //* Como el momento destacado de la cancion debe durar 5s, este no debe ser mayor a la duracion de la cancion -5s
                              if(_musicController.clipMoment! > _musicController.musicDuration! - const Duration(seconds: 5)) {return 'Fuera del limite';}
                              return null;
                            },
                          ),
                        ],
                      );
                    }
                  ),
                ),

                //* Imagen de musica
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TWSelectFile(
                    controller: _imageController,
                    loadStreamController: _imageFileUploadStreamController,
                    labelText: 'Imagen de musica (Opcional)',
                    message: 'Selecciona una imagen',
                    fileType: FileType.image,
                    megaBytesLimit: 10,
                    showImage: true,
                  )
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: RoundedLoadingButton(
                    controller: _btnController,
                    color: Colors.grey,
                    onPressed: onSubmit,
                    child: const Text('Subir musica', style: TextStyle(color: Colors.white)),
                  ),
                ),

                StreamBuilder<ButtonState>(
                  stream: _btnController.stateStream,
                  builder: (context, snapshot) {
                    if(snapshot.data == ButtonState.error  || snapshot.data == ButtonState.success){
                      return TextButton(onPressed: _btnController.reset, child: 
                        const Text('Reiniciar', style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          fontWeight: FontWeight.normal
                        )));
                    }
                    return const SizedBox.shrink();
                  },
                )

            ],
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    context.read<MusicCubit>().state.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _bestDurationController.dispose();
    _musicController.dispose();
    _imageController.dispose();

    _musicFileUploadStreamController.close();
    _imageFileUploadStreamController.close();
    super.dispose();
  }
}