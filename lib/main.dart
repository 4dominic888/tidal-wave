import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:tidal_wave/data/abstractions/connectivity_service_base.dart';
import 'package:tidal_wave/data/abstractions/database_service.dart';
import 'package:tidal_wave/locator.dart';
import 'package:tidal_wave/presentation/bloc/connectivity_cubit.dart';
import 'package:tidal_wave/presentation/bloc/download_music_cubit.dart';
import 'package:tidal_wave/presentation/bloc/music_color_cubit.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/presentation/bloc/music_playing_cubit.dart';
import 'package:tidal_wave/presentation/bloc/play_list_state_cubit.dart';
import 'package:tidal_wave/presentation/bloc/user_cubit.dart';
import 'package:tidal_wave/firebase_options.dart';
import 'package:tidal_wave/presentation/pages/home_page/home_page_screen.dart';

Future<void> main() async {

  ///* Para el get it
  setupLocator();

  //? Inicializa los widgets previamente para realizar las operaciones asincronas posteriores
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_tidal_wave'
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //? Inicializacion de las bases de datos
  await GetIt.I<DatabaseService<Map<String,dynamic>>>(instanceName: 'Firestore').init(); //* Nube
  await GetIt.I<DatabaseService<Map<String,dynamic>>>(instanceName: 'Sqflite').init(); //* Local

  GetIt.I<ConnectivityServiceBase>().init();

  runApp(const TidalWaveApp());
}

class TidalWaveApp extends StatefulWidget {
  const TidalWaveApp({super.key});

  @override
  State<TidalWaveApp> createState() => _TidalWaveAppState();
}

class _TidalWaveAppState extends State<TidalWaveApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MusicCubit()),
        BlocProvider(create: (_) => MusicColorCubit()),
        BlocProvider(create: (_) => UserCubit()),
        BlocProvider(create: (_) => ConnectivityCubit()),
        BlocProvider(create: (_) => DownloadMusicCubit()),
        BlocProvider(create: (_) => MusicPlayingCubit()),
        BlocProvider(create: (_) => PlayListStateCubit())
      ],
      child: OverlaySupport(
        child: MaterialApp(
          title: 'Tidal Wave',
          debugShowCheckedModeBanner: false,
          //* Tema por defecto
          theme: defaultTheme(context),
          home: const HomePageScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    GetIt.I<DatabaseService<Map<String,dynamic>>>(instanceName: 'Sqflite').close();
    super.dispose();
  }

  ThemeData defaultTheme(BuildContext context) => ThemeData(
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: Colors.grey.shade400,
      selectionColor: Colors.grey.shade400.withOpacity(0.4),
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)
    ),
    dialogTheme: DialogTheme(
      titleTextStyle: const TextStyle(color: Colors.grey),
      backgroundColor: Colors.grey.shade900,
      contentTextStyle: const TextStyle(color: Colors.grey),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStateTextStyle.resolveWith((states) => const TextStyle(color: Colors.white)),
        foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white)
      )
    ),
    textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white, decorationColor: Colors.white),
    primaryTextTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white, decorationColor: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(textStyle: WidgetStateTextStyle.resolveWith((states) => const TextStyle(color: Colors.blueAccent)),
      foregroundColor: WidgetStateColor.resolveWith((states) => states.isEmpty ? Colors.white : Colors.grey.shade800.withOpacity(0.7)),
    )),
    listTileTheme: const ListTileThemeData(
      titleTextStyle: TextStyle(color: Colors.white),
      subtitleTextStyle: TextStyle(color: Colors.white),
      iconColor: Colors.white
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    primaryIconTheme: const IconThemeData(color: Colors.white),
    inputDecorationTheme: const InputDecorationTheme(
      prefixIconColor: Colors.white,
      suffixIconColor: Colors.white
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.white),
    hintColor: Colors.white
  );
}
