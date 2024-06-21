import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tidal_wave/data/abstractions/connectivity_service_base.dart';
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

  GetIt.I<ConnectivityServiceBase>().init();

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
        //* Tema por defecto
        theme: ThemeData(
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
        ),
        home: const HomePageScreen(),
      ),
    );
  }
}
