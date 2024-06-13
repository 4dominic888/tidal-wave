import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:tidal_wave/shared/controllers/tw_select_file_controller.dart';
import 'package:tidal_wave/shared/widgets/tw_dropdownbutton_field.dart';
import 'package:tidal_wave/shared/widgets/tw_select_file.dart';
import 'package:tidal_wave/shared/widgets/tw_text_field.dart';

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
    if(_btnController.currentState == ButtonState.error){_btnController.reset(); return;}
    if(_formKey.currentState!.validate()){
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
                  items: const ['Publico', 'Privado', 'Offline'],
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