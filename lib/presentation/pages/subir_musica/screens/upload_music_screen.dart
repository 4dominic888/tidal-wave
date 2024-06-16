// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/presentation/pages/subir_musica/widgets/duration_form_field.dart';
import 'package:tidal_wave/services/firebase/firebase_storage_service.dart';
import 'package:tidal_wave/services/repositories/tw_music_repository.dart';
import 'package:tidal_wave/presentation/controllers/tw_select_file_controller.dart';
import 'package:tidal_wave/presentation/utils/music_state_util.dart';
import 'package:tidal_wave/presentation/utils/function_utils.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_select_file.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_text_field.dart';
import 'package:uuid/uuid.dart';

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

  final _musicFileUploadStreamController = StreamController<double>();
  final _imageFileUploadStreamController = StreamController<double>();

  bool _onLoad = false;

  void onSubmit() async {
    if(_formKey.currentState!.validate()){
      setState(() =>_onLoad = true);

      final String uuid = const Uuid().v4();
      final bool hasImage = _imageController.value != null;
      late final Result<String> imageUploadResult;

      final musicUploadResult = await FirebaseStorageService.uploadFile('music', 'm-$uuid', _musicController.value!, onLoad: (value) {
        _musicFileUploadStreamController.sink.add(
          value.bytesTransferred / value.totalBytes
        );
      });

      if (!musicUploadResult.onSuccess) {
        showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: musicUploadResult.errorMessage!));
        setState(() =>_onLoad = false);
        return;
      }

      if (hasImage) {
        imageUploadResult = await FirebaseStorageService.uploadFile('music-thumb', 'i-$uuid', _imageController.value!, onLoad: (value) {
          _imageFileUploadStreamController.sink.add(
            value.bytesTransferred / value.totalBytes
          );
        },);
        if(!imageUploadResult.onSuccess){
          FirebaseStorageService.deleteFileWithURL(musicUploadResult.data!);
          showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: imageUploadResult.errorMessage!));
          setState(() =>_onLoad = false);
          return;
        }
      }

      Music music = Music.byUID(
        -1,
        titulo: _titleController.text,
        artistas: [_artistController.text],
        musica: Uri.parse(musicUploadResult.data!),
        imagen: Uri.parse(imageUploadResult.data!),
        duration: _musicController.musicDuration!,
        stars: 0,
        uploadAt: Timestamp.now(),
        userId: FirebaseAuth.instance.currentUser!.uid,
        betterMoment: _musicController.clipMoment ?? Duration.zero
      );

      final finalResult = await TWMusicRepository().addOne(music, uuid);

      if (!finalResult.onSuccess) {
        FirebaseStorageService.deleteFileWithURL(musicUploadResult.data!);
        if(hasImage) {
          FirebaseStorageService.deleteFileWithURL(imageUploadResult.data!);
        }
        showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: finalResult.errorMessage!));
        setState(() =>_onLoad = false);
        return;
      }

      showDialog(context: context, builder: (context) => const PopupMessage(title: 'Exito', description: 'La cancion ha sido subida con exito a los servidores de tidal wave'));
      setState(() =>_onLoad = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
                      context.read<MusicCubit>().setClip(_musicController.value!.path, _musicController.clipMoment ?? Duration.zero);
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
                              const Text('Momento destacado:', style: TextStyle(color: Colors.white)),
                              const Text('Durara 5 segundos segun el tiempo establecido', style: TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
                              if(_musicController.value != null)
                                StreamBuilder<PlayerState>(
                                  stream: context.read<MusicCubit>().state.playerStateStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.data?.processingState == ProcessingState.completed) {
                                      context.read<MusicCubit>().setClip(_musicController.value!.path, _musicController.clipMoment ?? Duration.zero);
                                      context.read<MusicCubit>().state.pause();
                                    }
                                    return IconButton(
                                      onPressed: MusicStateUtil.playReturns<void Function()>(snapshot.data,
                                        playCase: context.read<MusicCubit>().state.play,
                                        stopCase: context.read<MusicCubit>().state.pause,
                                        playStatic: context.read<MusicCubit>().state.play,
                                      ),
                                      icon: MusicStateUtil.playIcon(snapshot.data, color: Colors.white)
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

                //* Upload music button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white
                    ),
                    onPressed: _onLoad ? null : onSubmit,
                    child: const Text('Subir musica')
                  ),
                ),

                //* Circular progress indicator
                _onLoad ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                ) : const SizedBox.shrink()
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