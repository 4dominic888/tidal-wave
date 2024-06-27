import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:tidal_wave/domain/use_case/interfaces/authentication_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/user_cubit.dart';
import 'package:tidal_wave/presentation/controllers/tw_select_file_controller.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_select_file.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_text_field.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  final _pfpController = TWSelectFileController();
  final _btnController = RoundedLoadingButtonController();

  final _pfpFileUploadStreamController = StreamController<double>();
  
  final _authenticationUseCase = GetIt.I<AuthenticationManagerUseCase>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: context.read<UserCubit>().state!.username);
  }

  void onUpdate() async{
    if(_formKey.currentState!.validate()){

      final usuarioActualizado = context.read<UserCubit>().state!.copyWith(
        username: _usernameController.text,
        pfp: Uri.parse(_pfpController.value!.path)
      );

      final result = await _authenticationUseCase.actualizarInformacionUsuario(usuarioActualizado, onLoad: (value) {
        _pfpFileUploadStreamController.sink.add(
          value.bytesTransferred / value.totalBytes
        );
      });
      if(!mounted) return;
      
      if(!result.onSuccess) {
        showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: result.errorMessage!));
        _btnController.error();
        return;
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
      appBar: AppBar(title: const Text('Actualizar Informacion')),
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
                  loadStreamController: _pfpFileUploadStreamController,
                  labelText: 'Foto de perfil',
                  message: 'Selecciona una imagen',
                  fileType: FileType.image,
                  megaBytesLimit: 10,
                  showImage: true,
                  validator: (_) {
                    if(_pfpController.value == null){
                      return 'Archivo no proporcionado';
                    }
                    return null;
                  },
                )
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: RoundedLoadingButton(
                  controller: _btnController,
                  color: Colors.green,
                  onPressed: onUpdate,
                  child: const Text('Actualizar informacion', style: TextStyle(color: Colors.white)),
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
              ),

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