// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:tidal_wave/modules/autenticacion_usuario/classes/tw_user.dart';
import 'package:tidal_wave/services/firebase_auth_service.dart';

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

  bool _onLoad = false;

  void onSubmit() async{
    if (_formKey.currentState!.validate()) {
      setState(() =>_onLoad = true);

      final TWUser user = TWUser(
        username: _usernameController.text, 
        type: "User",
        email: _emailController.text
      );

      final result = await FirebaseAuthService.registerUser(user, _passwordController.text);
      setState(() =>_onLoad = false);

      if (result.onSuccess) {
        showDialog(context: context, builder: (context) => const PopupMessage(title: 'Exito', description: 'Se ha registrado al usuario'));
      }
      else{
        showDialog(context: context, builder: (context) => PopupMessage(title: 'Ha ocurrido un error', description: result.errorMessage!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Registrate en Tidal Wave'),
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
                child: RegisterTextField(
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
                child: RegisterTextField(
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
                child: RegisterTextField(
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
                child: RegisterTextField(
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
              
              //* Submit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white
                  ),
                  onPressed: onSubmit,
                  child: const Text('Registrarse')
                ),
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
    super.dispose();
  }
}

class RegisterTextField extends StatelessWidget {

  final String hintText;
  final TextInputType? textInputType;
  final Icon? icon;
  final String? Function(String? value)? validator;
  final TextEditingController? controller;

  const RegisterTextField({
    super.key, required this.hintText, this.textInputType, this.icon, this.validator, this.controller
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: textInputType,
      obscureText: textInputType==TextInputType.visiblePassword,
      cursorColor: Colors.grey.shade500,
      autocorrect: false,
      enableSuggestions: false,
      style: TextStyle(color: Colors.grey.shade500),
      decoration: InputDecoration(
        suffixIcon: icon,
        suffixIconColor: Colors.grey,
        filled: true,
        fillColor: Colors.grey.shade900,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.transparent)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade600)
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.red.shade800)
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.red.shade400)
        ),
      ),
    );
  }
}

class PopupMessage extends StatelessWidget {

  final String title;
  final String description;

  const PopupMessage({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      backgroundColor: Colors.grey.shade900,
      content: Text(description, style: const TextStyle(color: Colors.grey)),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar', style: TextStyle(color: Colors.blueAccent)))
      ],
    );
  }
}