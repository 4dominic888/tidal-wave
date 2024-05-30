// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:tidal_wave/shared/controllers/tw_select_file_controller.dart';
import 'package:tidal_wave/shared/widgets/popup_message.dart';

class TWSelectFile extends StatefulWidget {

  final String message;
  final FileType fileType;
  final String labelText;
  final String? Function(File? value)? validator;
  final TWSelectFileController? controller;
  final int megaBytesLimit;

  ///* Mostrar imagen solo si el tipo de archivo es una imagen
  final bool? showImage;

  const TWSelectFile({
    super.key, 
    required this.message,
    required this.fileType,
    required this.labelText,
    required this.megaBytesLimit,
    this.showImage = false,
    this.validator,
    this.controller,
  });

  @override
  State<TWSelectFile> createState() => _TWSelectFileState();
}

class _TWSelectFileState extends State<TWSelectFile> {

  late String _message;
  late bool _showImage = false;
  File? _file;

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
    return FormField<File>(
      validator: widget.validator,
      builder: (formState) {
        return InputDecorator(
          decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.grey.shade500),
            labelText: widget.labelText,
            errorText: formState.hasError ? formState.errorText : null,
          ),
          child: Column(
            children: [

              //* Selectable file
              InkWell(
                onTapUp: (_) async {
                  if(widget.fileType == FileType.image){
                    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if(result == null) {
                      _file = null;
                      widget.controller?.setValue = _file;
                      return;
                    }
                    _file = File(result.path);

                    final croppedFile = await ImageCropper().cropImage(
                      sourcePath: _file!.path,
                      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
                      aspectRatioPresets: [
                        CropAspectRatioPreset.square,
                      ],
                      uiSettings: [
                        AndroidUiSettings(
                          toolbarTitle: 'Recortar imagen',
                          toolbarColor: Colors.grey.shade700,
                          toolbarWidgetColor: Colors.white,
                          initAspectRatio: CropAspectRatioPreset.square,
                          lockAspectRatio: true
                        ),
                      ],
                    );

                    if(croppedFile == null){
                      _file = null;
                      widget.controller?.setValue = _file;
                      return;
                    }
                    _file = File(croppedFile.path);
                    _showImage = true;
                    widget.controller?.setValue = _file;
                  }
                  else{
                    final FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: widget.fileType,
                      withData: true
                    );

                    if(result == null){
                      _file = null;

                      widget.controller?.setValue = _file;
                      return;
                    }

                    _file = File(result.files.first.path!);
                    widget.controller?.setValue = _file;
                  }

                  if(_file!.lengthSync() >= widget.megaBytesLimit*1000000){
                    await showDialog(context: context, builder: (context) => PopupMessage(title: 'Advertencia', description: 'El archivo no debe ser mayor a ${widget.megaBytesLimit} MB'));
                    _file = null;
                    widget.controller?.setValue = _file;
                    return;
                  }
                  
                  String size = await _fileSizeStr(_file);
                  setState(() => _message = '${basename(_file!.path)} - $size');

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
        
              //* Imagen si lo hubiera
              if(widget.showImage! && widget.fileType == FileType.image && _showImage)
                if(_file != null)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 10,
                            )
                          ),
                          child: Image.memory(
                            _file!.readAsBytesSync(),
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),
                    ],
                  )
              else const SizedBox.shrink()
            ],
          ),
        );
      }
    );
  }
}