import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/modules/lista_musica/screens/lista_musica_screen.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';
import 'package:tidal_wave/static_music.dart';

Future<void> main() async {
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

    List<Music> playListTest = StaticMusic.musicas;

    //? Usar para testear listas largas
    //List<Music> duplicatedList = List.generate(16, (_) => playListTest).expand((element) => element).toList();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MusicCubit())
      ],

      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        
        //? Codigo para cambiar la bolita esa de los textos
        theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: Colors.grey.shade400,
            selectionColor: Colors.grey.shade400.withOpacity(0.4),
          ),
        ),
        home: ListaMusicaScreen(listado: playListTest),
      ),
    );
  }
}
