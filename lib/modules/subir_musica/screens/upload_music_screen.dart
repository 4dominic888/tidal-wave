import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tidal_wave/shared/tw_select_file.dart';
import 'package:tidal_wave/shared/tw_text_field.dart';

class UploadMusicScreen extends StatelessWidget {
  const UploadMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

              //* Titulo
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWTextField(
                  hintText: 'Titulo',
                  textInputType: TextInputType.emailAddress,
                  icon: Icon(Icons.text_fields_rounded),
                ),
              ),

              //* Artista
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWTextField(
                  hintText: 'Artista',
                  textInputType: TextInputType.emailAddress,
                  icon: Icon(Icons.person_2_sharp),
                ),
              ),

              //* Musica file
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWSelectFile(
                  labelText: 'Musica',
                  message: 'Selecciona el archivo de musica',
                  fileType: FileType.audio,
                )
              ),

              //* Imagen de musica
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWSelectFile(
                  labelText: 'Imagen de musica (Opcional)',
                  message: 'Selecciona una imagen',
                  fileType: FileType.image,
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
                  onPressed: (){},
                  child: const Text('Subir musica')
                ),
              ),

          ],
        ),
      ),
    );
  }
}