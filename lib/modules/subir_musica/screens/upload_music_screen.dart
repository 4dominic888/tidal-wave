// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:audio_duration/audio_duration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';
import 'package:tidal_wave/services/firebase_storage_service.dart';
import 'package:tidal_wave/services/repositories/tw_music_repository.dart';
import 'package:tidal_wave/shared/controllers/tw_select_file_controller.dart';
import 'package:tidal_wave/shared/popup_message.dart';
import 'package:tidal_wave/shared/result.dart';
import 'package:tidal_wave/shared/tw_select_file.dart';
import 'package:tidal_wave/shared/tw_text_field.dart';
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

      final int durationMs = await AudioDuration.getAudioDuration(_musicController.value!.path) ?? 0;

      Music music = Music.byUID(
        -1,
        titulo: _titleController.text,
        artistas: [_artistController.text],
        musica: Uri.parse(musicUploadResult.data!),
        imagen: Uri.parse(imageUploadResult.data!),
        duration: Duration(milliseconds: durationMs),
        stars: 0,
        uploadAt: Timestamp.now(),
        userId: FirebaseAuth.instance.currentUser!.uid,
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
                      if(value == null || value.trim().isEmpty){
                        return "Campo no proporcionado";
                      }
                      if(value.length <= 2 || value.length > 50){
                        return "El campo debe ser mayor a 2 y menor a 50 caracteres";
                      }
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
                      if(value == null || value.trim().isEmpty){
                        return "Campo no proporcionado";
                      }
                      if(value.length <= 2 || value.length > 50){
                        return "El campo debe ser mayor a 2 y menor a 50 caracteres";
                      }
                      return null;
                    },
                  ),
                ),
                
                //* Musica file
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TWSelectFile(
                    controller: _musicController,
                    labelText: 'Musica',
                    message: 'Selecciona el archivo de musica',
                    fileType: FileType.audio,
                    megaBytesLimit: 20,
                    validator: (_) {
                      if(_musicController.value == null){
                        return "Archivo no proporcionado";
                      }
                      return null;
                    },
                  )
                ),

                //* Progress bar music file
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                  child: StreamBuilder<double>(
                    stream: _musicFileUploadStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.data! > 0 && snapshot.data! < 1) {
                        return LinearProgressIndicator(
                          value: snapshot.data,
                          color: snapshot.data! >= 1 ? Colors.green : Colors.blueAccent,
                        );
                      }
                      else{
                        return const SizedBox.shrink();
                      }
                    }
                  ),
                ),

                //* Imagen de musica
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TWSelectFile(
                    controller: _imageController,
                    labelText: 'Imagen de musica (Opcional)',
                    message: 'Selecciona una imagen',
                    fileType: FileType.image,
                    megaBytesLimit: 10,
                    showImage: true,
                  )
                ),

                //* Progress bar image file
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                  child: StreamBuilder<double>(
                    stream: _imageFileUploadStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.data! > 0 && snapshot.data! < 1) {
                        return LinearProgressIndicator(
                          value: snapshot.data,
                          color: snapshot.data! >= 1 ? Colors.green : Colors.blueAccent,
                        );
                      }
                      else{
                        return const SizedBox.shrink();
                      }
                    }
                  ),
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
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _musicController.dispose();
    _imageController.dispose();

    _musicFileUploadStreamController.close();
    _imageFileUploadStreamController.close();
    super.dispose();
  }
}