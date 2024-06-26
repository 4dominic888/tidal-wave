import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tidal_wave/domain/use_case/interfaces/authentication_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/user_cubit.dart';
import 'package:tidal_wave/domain/models/tw_user.dart';
import 'package:tidal_wave/presentation/pages/autenticacion_usuario/screens/login_screen.dart';
import 'package:tidal_wave/presentation/pages/autenticacion_usuario/screens/register_screen.dart';
import 'package:tidal_wave/presentation/pages/autenticacion_usuario/screens/update_user_screen.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';

class TWAccountNav extends StatelessWidget {
  const TWAccountNav({super.key});

  static List<Map<String, String>> userFields(String type, String email, String timeStamp) => [
    {'Tipo de usuario': type},
    {'Email': email},
    {'Unido desde': timeStamp},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, TWUser?>(
      builder: (context, snapshot) {
        return SingleChildScrollView(
          child: snapshot != null ? Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade400,
                foregroundImage: snapshot.pfp != null ? CachedNetworkImageProvider(snapshot.pfp!.toString()) : null,
              ),
        
              const SizedBox(height: 10),
        
              Text(
                '# ${snapshot.username}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        
              const SizedBox(height: 5),
        
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Table(
                  border: TableBorder(
                    verticalInside: BorderSide(
                      color: Colors.grey.shade100.withOpacity(0.1)
                    )
                  ),
                  children: userFields(snapshot.type, snapshot.email, snapshot.readCreatedAt).map((e) => TableRow(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      border: Border.all(color: Colors.grey.shade100.withOpacity(0.1))
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e.keys.first),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(e.values.first)
                        ),
                      ),
                    ]
                  )).toList(),
                ),
              ),
        
              Wrap(
                runSpacing: 10,
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(onPressed: null, style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ), child: const Text('Cambiar contraseña')),
        
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text('Editar cuenta'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UpdateUserScreen()));
                    },
                  ),
        
                  ElevatedButton(onPressed: (){
                    showDialog(context: context, builder: (context) => 
                      PopupDialog(
                        title: 'Advertencia',
                        description: '¿Estás seguro de que quieres cerrar sesión?',
                        onOK: () async {
                          await GetIt.I<AuthenticationManagerUseCase>().salirDeLaCuenta();
                          if(!context.mounted) return;
                          context.read<UserCubit>().user = null;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                        },
                        ),
                      );
                  }, style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ), child: const Text('Salir de la cuenta')),
                ],
              )
        
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
        
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Parece que no estas usando una cuenta ahora mismo, registrate o inicia sesion ahora',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),          
        
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                ), child: const Text('Iniciar sesion')),
              ),
        
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                ), child: const Text('Registrarse')),
              ),
            ]
          ),
        );
      }
    );
  }
}