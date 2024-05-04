import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';
import 'package:tidal_wave/modules/reproductor_musica/screens/reproductor_musica_screen.dart';

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


    List<Music> playListTest = [
      Music(
        titulo: 'Babaroque (WHAT Ver.)',
        artista: 'cYsmix',
        musica: Uri.parse('asset:/assets/music/cYsmix - Babaroque (WHAT Ver.).mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/jXy6YCpJnQM/hqdefault.jpg')
      ),
      Music(
        titulo: 'Phone Me First',
        artista: 'cYsmix',
        musica: Uri.parse('asset:/assets/music/cYsmix - Phone Me First.mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/uDYdecWY85w/hqdefault.jpg')
      ),
      Music(
        titulo: 'Eight O\'Eigh',
        artista: 'Demonicity',
        musica: Uri.parse('asset:/assets/music/Demonicity - Eight O\'Eight.mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/ksZb4xKOdzI/hqdefault.jpg')
      )
    ];

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: ReproductorMusicaScreen(listOfMusic: playListTest),
    );
  }
}
