import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const ReproductorMusicaScreen(),
    );
  }
}
