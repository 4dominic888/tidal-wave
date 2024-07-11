// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:tidal_wave/domain/use_case/interfaces/authentication_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/user_cubit.dart';
import 'package:tidal_wave/domain/models/tw_user.dart';
import 'package:tidal_wave/presentation/global_widgets/tidal_wave_logo.dart';
import 'package:tidal_wave/presentation/pages/home_page/home_page_screen.dart';
import 'package:tidal_wave/presentation/global_widgets/tw_text_field.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _emailVal = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final RegExp _upperRegex = RegExp(r'(?=.*[A-Z])');
  final RegExp _lowerRegex = RegExp(r'(?=.*[a-z])');
  final RegExp _digitRegex = RegExp(r'(?=.*[0-9])');
  final RegExp _specialRegex = RegExp(r'(?=.*[!@#$%^&*()\-_=+{};:,<.>])');
  final RegExp _lengthRegex = RegExp(r'.{8,}');


  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyPasswordController = TextEditingController();
  final _btnController = RoundedLoadingButtonController();


  final _authenticationUseCase = GetIt.I<AuthenticationManagerUseCase>();

  void onSubmit() async{
    if (_formKey.currentState!.validate()) {
      final TWUser user = TWUser(
        username: _usernameController.text, 
        type: "User",
        email: _emailController.text
      );

      final result = await _authenticationUseCase.registrarse(user, _passwordController.text);

      if (result.onSuccess) {
        context.read<UserCubit>().user = user;
        showDialog(context: context, builder: (context) => 
          PopupMessage(
            title: 'Exito',
            description: 'Se ha registrado al usuario',
            onClose: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePageScreen())),
          ),
          barrierDismissible: false
        );
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
      appBar: AppBar(title: const Text('Registrarse')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            verticalDirection: VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              //* Logo
              const TidalWaveLogo(size: 150),

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
                    if(!_upperRegex.hasMatch(value)){
                      return "Debe tener al menos una letra mayuscula";
                    }
                    if(!_lowerRegex.hasMatch(value)){
                      return "Debe tener al menos una letra minuscula";
                    }
                    if(!_digitRegex.hasMatch(value)){
                      return "Debe tener al menos un dígito";
                    }
                    if(!_specialRegex.hasMatch(value)){
                      return "Debe tener al menos un carácter especial";
                    }
                    if(!_lengthRegex.hasMatch(value)){
                      return "Debe tener al menos 8 caracteres de longitud";
                    }
                    return null;
                  },
                ),
              ),

              //* Verify password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TWTextField(
                  controller: _verifyPasswordController,
                  hintText: 'Verificar contraseña',
                  textInputType: TextInputType.visiblePassword,
                  icon: const Icon(Icons.lock_clock_rounded),
                  validator: (value) {
                    if(_passwordController.text != value){
                      return "Las contraseñas no coinciden";
                    }
                    return null;
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: RoundedLoadingButton(
                  controller: _btnController,
                  color: Colors.green,
                  onPressed: onSubmit,
                  child: const Text('Registrarse', style: TextStyle(color: Colors.white)),
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

              //* Login navigator
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTapUp: (_) {},
                    child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                      child: const Text('¿Tienes una cuenta? Inicie sesión', style: TextStyle(color: Colors.grey))
                    )
                  )
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
    super.dispose();
  }
}