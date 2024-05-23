import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tidal_wave/bloc/music_color_cubit.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/bloc/play_list_cubit.dart';
import 'package:tidal_wave/bloc/user_cubit.dart';
import 'package:tidal_wave/firebase_options.dart';
import 'package:tidal_wave/modules/home_page/screens/home_page_screen.dart';
import 'package:tidal_wave/services/repositories/tw_user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demon_channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true
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

          FirebaseAuth.instance.authStateChanges().listen((user) async {
            if (user?.uid != null) {
              final twur = TWUserRepository();
              final result = await twur.getOne(user!.uid);
              // ignore: use_build_context_synchronously
              context.read<UserCubit>().user = result.data;
            }
            else{
              context.read<UserCubit>().user = null;
            }
          });

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
