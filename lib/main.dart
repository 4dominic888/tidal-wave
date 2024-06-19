import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tidal_wave/locator.dart';
import 'package:tidal_wave/presentation/bloc/music_color_cubit.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/presentation/bloc/user_cubit.dart';
import 'package:tidal_wave/firebase_options.dart';
import 'package:tidal_wave/presentation/pages/home_page/screens/home_page_screen.dart';

Future<void> main() async {

  ///* Para el get it
  setupLocator();

  //? Inicializa los widgets previamente para realizar las operaciones asincronas posteriores
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //* Configuracion para persistencia de datos, solo funciona para firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
  );
  runApp(const TidalWaveApp());
}

class TidalWaveApp extends StatelessWidget {
  const TidalWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MusicCubit()),
        BlocProvider(create: (_) => MusicColorCubit()),
        BlocProvider(create: (_) => UserCubit())
      ],
      child: MaterialApp(
        title: 'Tidal Wave',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: Colors.grey.shade400,
            selectionColor: Colors.grey.shade400.withOpacity(0.4),
          ),
        ),
        home: const HomePageScreen(),
      ),
    );
  }
}
