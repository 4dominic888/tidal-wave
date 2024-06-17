import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/data/dataSources/firebase/firebase_storage_service.dart';
import 'package:tidal_wave/data/repositories/repository_implement_base.dart';
import 'package:tidal_wave/data/repositories/tw_music_list_repository_implement.dart';
import 'package:tidal_wave/presentation/controllers/tw_select_file_controller.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_dropdownbutton_field.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_select_file.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_text_field.dart';
import 'package:uuid/uuid.dart';

class CreateUserListScreen extends StatefulWidget {
  const CreateUserListScreen({super.key});

  @override
  State<CreateUserListScreen> createState() => _CreateUserListScreenState();
}

class _CreateUserListScreenState extends State<CreateUserListScreen> {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeListController = TextEditingController();
  final _imageController = TWSelectFileController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  
  final _imageFileUploadStreamController = StreamController<double>();

  //bool _onLoad = false;

  void onSubmit() async{
    if(_formKey.currentState!.validate()){

      final String uuid = const Uuid().v4();
      late final Result<String> imageUploadResult;
      if(_imageController.value != null){
        imageUploadResult = await FirebaseStorageService.uploadFile('list-thumb', 'l-$uuid', _imageController.value!, onLoad: (value) {
          _imageFileUploadStreamController.sink.add(
            value.bytesTransferred / value.totalBytes
          );
        });
      }
      if(!mounted) return;

      if(!imageUploadResult.onSuccess){
        showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: imageUploadResult.errorMessage!));
        _btnController.error();
        return;
      }

      final MusicList musicList = MusicList.toSend(
        name: _nameController.text,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text : 'No proporcionado',
        type: _typeListController.text,
        image: Uri.parse(imageUploadResult.data!)
      );

      final musicListResult = await TWMusicListRepositoryImplement(TypeDataBase.firestore).addOne(musicList, null);
      if(!musicListResult.onSuccess){
        if(_imageController.value != null) {FirebaseStorageService.deleteFileWithURL(imageUploadResult.data!);}
        if(!mounted) return;
        showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: musicListResult.errorMessage!));
        _btnController.error();
        return;
      }

      if(!mounted) return;
      showDialog(context: context, builder: (context) => const PopupMessage(title: 'Exito', description: 'La lista ha sido creada satisfactoriamente'));
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
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        title: const Text('Crear nueva lista'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWTextField(
                  controller: _nameController,
                  hintText: 'Nombre de la lista',
                  textInputType: TextInputType.name,
                  icon: const Icon(Icons.text_fields_rounded),
                  validator: (value) {
                    if(value == null || value.trim().isEmpty) {return "Campo no proporcionado";}
                    if(value.length <= 2 || value.length > 50) {return "El campo debe ser mayor a 2 y menor a 50 caracteres";}
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWTextField(
                  controller: _descriptionController,
                  hintText: 'Descripcion (opcional)',
                  textInputType: TextInputType.multiline,
                  icon: const Icon(Icons.text_snippet_rounded),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWDropdownbuttonField(
                  controller: _typeListController,
                  label: 'Tipo de lista',
                  icon: const Icon(Icons.type_specimen_rounded),
                  items: const [{'Publico':'public-list'}, {'Privado':'private-list'}, {'Offline':'offline-list'}],
                )
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWSelectFile(
                  controller: _imageController,
                  loadStreamController: _imageFileUploadStreamController,
                  labelText: 'Imagen de lista (Opcional)',
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
                  color: Colors.purple,
                  onPressed: onSubmit,
                  child: const Text('Crear lista', style: TextStyle(color: Colors.white)),
                ),
              ),

              StreamBuilder<ButtonState>(
                stream: _btnController.stateStream,
                builder: (context, snapshot) {
                  if(snapshot.data == ButtonState.error  || snapshot.data == ButtonState.success){
                    return TextButton(onPressed: _btnController.reset, child: 
                      const Text('Reiniciar', style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                        fontWeight: FontWeight.normal
                      )));
                  }
                  return const SizedBox.shrink();
                },
              )
            ],
          )
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _typeListController.dispose();
    _imageFileUploadStreamController.close();
    super.dispose();
  }
}