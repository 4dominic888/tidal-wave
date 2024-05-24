import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

              //* Musica file
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWSelectFile(
                  labelText: 'Imagen de musica (Opcional)',
                  message: 'Selecciona una imagen',
                  fileType: FileType.image,
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

class TWSelectFile extends StatefulWidget {

  final String message;
  final FileType fileType;
  final String labelText;

  const TWSelectFile({
    super.key, required this.message, required this.fileType, required this.labelText,
  });

  @override
  State<TWSelectFile> createState() => _TWSelectFileState();
}

class _TWSelectFileState extends State<TWSelectFile> {

  late String _message;
  late File? _file;

  @override
  void initState() {
    super.initState();
    _message = widget.message;
  }

  Future<String> _fileSizeStr(File? file) async {
    if (file == null) {
      return '0 B';
    }

    int bytes = await file.length();

    if (bytes > 1000000) {
      return '${(bytes/1000000).toStringAsFixed(2)} MB';
    }

    if (bytes > 1000) {
      return '${(bytes/1000).toStringAsFixed(2)} KB';
    }

    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.grey.shade500),
        labelText: widget.labelText,
        border: InputBorder.none
      ),
      child: InkWell(
        onTapUp: (_) async {
          final FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: widget.fileType,
            allowMultiple: false,
            withReadStream: true
          );
      
          if(result != null){
            _file = File(result.files.single.path!);
            String size = await _fileSizeStr(_file); 
            setState(() => _message = '${result.names.first} - $size' );
          }
          else{
            _file = null;
            setState(() => _message = widget.message);
          }
      
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          color: Colors.grey.shade900,
          child: DottedBorder(
            color: Colors.grey.shade600,
            strokeCap: StrokeCap.butt,
            strokeWidth: 2,
            dashPattern: const [10,5],
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(_message, 
                    style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                ),
              )
            ),
          ),
        ),
      ),
    );
  }
}