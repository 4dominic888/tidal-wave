// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:tidal_wave/domain/use_case/interfaces/authentication_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/user_cubit.dart';
import 'package:tidal_wave/presentation/global_widgets/tidal_wave_logo.dart';
import 'package:tidal_wave/presentation/pages/home_page/home_page_screen.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_text_field.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailVal = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _btnController = RoundedLoadingButtonController();


  final _authenticationUseCase = GetIt.I<AuthenticationManagerUseCase>();


  void onLogin() async {
    if(_formKey.currentState!.validate()){
      final result = await _authenticationUseCase.iniciarSesion(_emailController.text, _passwordController.text);
      if (result.onSuccess) {
        context.read<UserCubit>().user = result.data!;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePageScreen()));
        _btnController.success();
        return; 
      }
      showDialog(context: context, builder: (context) => PopupMessage(title: 'Error', description: result.errorMessage!));
      _btnController.error();
    }
    _btnController.error();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesion')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            verticalDirection: VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //* Logo
              const TidalWaveLogo(size: 150),

              //* Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  textInputType: TextInputType.emailAddress,
                  icon: const Icon(Icons.email_rounded),
                  validator: (value) {
                    if(!_emailVal.hasMatch(value!)){
                      return "El formato de email es incorrecto";
                    }
                    return null;
                  },
                ),
              ),

              //* Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWTextField(
                  controller: _passwordController,
                  hintText: 'Contraseña',
                  textInputType: TextInputType.visiblePassword,
                  icon: const Icon(Icons.lock_rounded),
                  validator: (value) {
                    if(value == null || value.isEmpty){
                      return "Campo no proporcionado";
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: RoundedLoadingButton(
                  controller: _btnController,
                  color: Colors.blue,
                  onPressed: onLogin,
                  child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white)),
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
              )

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}