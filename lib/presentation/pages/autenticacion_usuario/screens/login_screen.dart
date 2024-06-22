// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tidal_wave/domain/use_case/interfaces/authentication_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/user_cubit.dart';
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

  bool _onLoad = false;
  final _authenticationUseCase = GetIt.I<AuthenticationManagerUseCase>();


  void onLogin() async {
    if(_formKey.currentState!.validate()){
      setState(() =>_onLoad = true);
      final result = await _authenticationUseCase.iniciarSesion(_emailController.text, _passwordController.text);
      setState(() =>_onLoad = false);
      if (result.onSuccess) {
        context.read<UserCubit>().user = result.data!;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePageScreen()));
      }
      else{
        showDialog(context: context, builder: (context) => PopupMessage(title: 'Ha ocurrido un error', description: result.errorMessage!));
      }
    }
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
              const FlutterLogo(style: FlutterLogoStyle.stacked, size: 250),

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

              //* Login button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: _onLoad ? null : onLogin,
                  child: const Text('Iniciar sesión')
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}