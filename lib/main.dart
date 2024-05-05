import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tidal_wave/modules/lista_musica/screens/lista_musica_screen.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';

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
        imagen: Uri.parse('https://i.ytimg.com/vi/jXy6YCpJnQM/hqdefault.jpg'),
        duration: const Duration(minutes: 1, seconds: 11)
      ),
      Music(
        titulo: 'Phone Me First',
        artista: 'cYsmix',
        musica: Uri.parse('asset:/assets/music/cYsmix - Phone Me First.mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/uDYdecWY85w/hqdefault.jpg'),
        duration: const Duration(minutes: 2, seconds: 47)
      ),
      Music(
        titulo: 'Eight O\'Eigh',
        artista: 'Demonicity',
        musica: Uri.parse('asset:/assets/music/Demonicity - Eight O\'Eight.mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/ksZb4xKOdzI/hqdefault.jpg'),
        duration: const Duration(minutes: 3, seconds: 16)
      )
    ];

    List<Music> duplicatedList = List.generate(6, (_) => playListTest).expand((element) => element).toList();

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
      home: ListaMusicaScreen(listado: duplicatedList),
    );
  }
}
