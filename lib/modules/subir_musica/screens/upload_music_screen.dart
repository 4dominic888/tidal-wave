import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tidal_wave/shared/controllers/tw_select_file_controller.dart';
import 'package:tidal_wave/shared/tw_select_file.dart';
import 'package:tidal_wave/shared/tw_text_field.dart';

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

  void onSubmit(){
    if(_formKey.currentState!.validate()){

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
                    validator: (value) {
                      if(value == null){
                        return "Archivo no proporcionado";
                      }
                      return null;
                    },
                  )
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
          
                //* Login button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white
                    ),
                    onPressed: onSubmit,
                    child: const Text('Subir musica')
                  ),
                ),

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
    super.dispose();
  }
}