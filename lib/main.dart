import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidal_wave/bloc/music_color_cubit.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/bloc/play_list_cubit.dart';
import 'package:tidal_wave/bloc/user_cubit.dart';
import 'package:tidal_wave/firebase_options.dart';
import 'package:tidal_wave/modules/home_page/screens/home_page_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    //List<Music> playListTest = StaticMusic.musicas;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MusicCubit()),
        BlocProvider(create: (_) => PlayListCubit()),
        BlocProvider(create: (_) => MusicColorCubit()),
        BlocProvider(create: (_) => UserCubit())
      ],

      child: Builder(
        builder: (context) {

          return MaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            
            //? Codigo para cambiar la bolita esa de los textos
            theme: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                selectionHandleColor: Colors.grey.shade400,
                selectionColor: Colors.grey.shade400.withOpacity(0.4),
              ),
            ),
            home: const HomePageScreen(),
          );
        }
      ),
    );
  }
}
