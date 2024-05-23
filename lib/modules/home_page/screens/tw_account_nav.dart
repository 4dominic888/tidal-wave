import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidal_wave/bloc/user_cubit.dart';
import 'package:tidal_wave/modules/autenticacion_usuario/classes/tw_user.dart';

class TWAccountNav extends StatelessWidget {

  const TWAccountNav({super.key});

  static List<Map<String, String>> userFields = [
    {'Tipo de usuario': 'Artista'},
    {'Email': 'pepeasd@gmail.com.pe'},
    {'Unido desde': 'Alguna fecha'},

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
              ),
        
              const SizedBox(height: 10),
        
              const Text(
                '# Pepito Juarez',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
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
                  children: userFields.map((e) => TableRow(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      border: Border.all(color: Colors.grey.shade100.withOpacity(0.1))
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e.keys.first, style: const TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e.values.first, style: const TextStyle(color: Colors.white)),
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
                  ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white
                  ), child: const Text('Cambiar contraseña')),
        
                  ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white
                  ), child: const Text('Editar cuenta')),
        
                  ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white
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
                    color: Colors.white,
                  ),
                ),
              ),          
        
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white
                ), child: const Text('Iniciar sesion')),
              ),
        
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white
                ), child: const Text('Registrarse')),
              ),
            ]
          ),
        );
      }
    );
  }
}