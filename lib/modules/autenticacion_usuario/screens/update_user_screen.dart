import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidal_wave/bloc/user_cubit.dart';
import 'package:tidal_wave/services/firebase/firebase_auth_service.dart';
import 'package:tidal_wave/services/firebase/firebase_storage_service.dart';
import 'package:tidal_wave/shared/controllers/tw_select_file_controller.dart';
import 'package:tidal_wave/shared/widgets/popup_message.dart';
import 'package:tidal_wave/shared/widgets/tw_select_file.dart';
import 'package:tidal_wave/shared/widgets/tw_text_field.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _pfpController = TWSelectFileController();

  final _pfpFileUploadStreamController = StreamController<double>();
  
  bool _onLoad = false;

  void onUpdate() async{
    if(_formKey.currentState!.validate()){
      setState(() =>_onLoad = true);
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final pfpResult = await FirebaseStorageService.uploadFile('user-pfp', 'u-$userId', _pfpController.value!, onLoad: (value) {
        _pfpFileUploadStreamController.sink.add(
          value.bytesTransferred / value.totalBytes
        );
      });

      if(!mounted) return;

      if(!pfpResult.onSuccess){
        showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: pfpResult.errorMessage!));
        setState(() =>_onLoad = false);
        return;
      }

      FirebaseAuthService.updateNormalInfo(context.read<UserCubit>().state!.copyWith(
          username: _usernameController.text,
          pfp: Uri.parse(pfpResult.data!)
        )).then((value) {
          if(!mounted) return;
          if(!value.onSuccess){
            setState(() =>_onLoad = false);
            showDialog(context: context, builder: (context) => PopupMessage(title: 'Ha ocurrido un error', description: value.errorMessage!));
            return;
          }
          showDialog(context: context, builder: (context) => PopupMessage(title: 'Exito', description: value.data!));

          setState(() =>_onLoad = false);
      });

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
            verticalDirection: VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.stretch,          
            children: [
              //* Logo
              const FlutterLogo(style: FlutterLogoStyle.stacked, size: 250),

              //* Username
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWTextField(
                  controller: _usernameController,
                  hintText: 'Nombre de usuario',
                  icon: const Icon(Icons.person_2_rounded),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Campo vacio";
                    }
                    value = value.trim().replaceAll(RegExp(r'\s+'), ' ');
                    if (value.length <= 1) {
                      return "El nombre de usuario debe ser mayor a 1 caracteres";
                    }
                    if (value.length > 25) {
                      return "El nombre de usuario no debe exceder de 25 caracteres";
                    }
                    return null;
                  },
                ),
              ),

                //* PFP
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TWSelectFile(
                    controller: _pfpController,
                    labelText: 'Foto de perfil',
                    message: 'Selecciona una imagen',
                    fileType: FileType.image,
                    megaBytesLimit: 10,
                    showImage: true,
                  )
                ),

                //TODO mover esto xd
                //* Progress bar pfp file
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                  child: StreamBuilder<double>(
                    stream: _pfpFileUploadStreamController.stream,
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

              //* Submit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white
                  ),
                  onPressed: _onLoad ? null : onUpdate,
                  child: const Text('Actualizar informacion')
                ),
              ),

              //* Circular progress indicator
              _onLoad ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
              ) : const SizedBox.shrink()

            ],
        )),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pfpController.dispose();
    _pfpFileUploadStreamController.close();
    super.dispose();
  }
}