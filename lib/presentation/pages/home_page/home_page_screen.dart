import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tidal_wave/domain/use_case/interfaces/authentication_manager_use_case.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/presentation/bloc/user_cubit.dart';
import 'package:tidal_wave/presentation/pages/autenticacion_usuario/screens/login_screen.dart';
import 'package:tidal_wave/presentation/pages/autenticacion_usuario/screens/register_screen.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/screens/lista_musica_screen.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/tw_drawer.dart';
import 'package:tidal_wave/presentation/pages/subir_musica/screens/upload_music_screen.dart';
import 'package:tidal_wave/presentation/pages/home_page/user_account_nav/screens/tw_account_nav.dart';
import 'package:tidal_wave/presentation/pages/home_page/find_music_nav/screens/tw_find_nav.dart';
import 'package:tidal_wave/presentation/pages/home_page/home_nav/screens/tw_home_nav.dart';
import 'package:tidal_wave/presentation/pages/home_page/user_list_nav/screens/tw_user_list_nav.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _authenticationUseCase = GetIt.I<AuthenticationManagerUseCase>();
  final _musicManagerUseCase = GetIt.I<MusicManagerUseCase>();


  int _selectedIndex = 0;

  Widget _currentScreen(int index){
    switch (index) {
      case 0: return const TWHomeNav();
      case 1: return const TWFindNav();
      case 2: return const TWUserListNav();
      case 3: return const TWAccountNav();
      default: return const SizedBox.shrink();
    }
  }

  final List<Map<String, Icon>> _titleArray = [
    {'Home': const Icon(Icons.home_rounded)}, 
    {'Buscar': const Icon(Icons.search_rounded)},
    {'Tus listas': const Icon(Icons.library_music_rounded)},
    {'Cuenta': const Icon(Icons.account_box)}
  ];

  Future<void> validateAndGetUser() async {
    final result = await _authenticationUseCase.obtenerUsuarioActual();
    if(!mounted) return;
    context.read<UserCubit>().user = result.data; 
  }

  final List<Map<String, void Function()>> _drawerOptions = [];

  @override
  Widget build(BuildContext context) {

    FirebaseAuth.instance.authStateChanges().listen((user) async => await validateAndGetUser());

    _drawerOptions.clear();

    if(context.read<UserCubit>().state == null){
      _drawerOptions.addAll([
        { "Iniciar sesion": () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())) },
        { "Registrarse":    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())) }
      ]);
    }
    else{
      _drawerOptions.addAll([
        {"Canciones favoritas": (){}},
        {"Historial de canciones": (){}},
        {"Sube tu canción": () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadMusicScreen())) },
        {"Lista old": () async {
          final tempList = await _musicManagerUseCase.obtenerCancionesPublicas();
          if(!context.mounted) return;
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListaMusicaScreen(listado: tempList.data ?? [])));
        }}
      ]);
    }
    _drawerOptions.add({
      "Opciones": (){}
    });

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.grey.shade900.withOpacity(0.6),
        toolbarHeight: 0,
        elevation: 0,
      ),
      drawer: TWDrawer(options: _drawerOptions),
      onDrawerChanged: (isOpened) => setState(() {}),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        backgroundColor: Colors.grey.shade900,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.grey.shade300,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        onTap: (value) => setState(() => _selectedIndex = value),
        items: _titleArray.map((e) => BottomNavigationBarItem(icon: e.values.first, label: e.keys.first)).toList(),        
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 30, 114, 138),Color(0xFF071A2C)]
          )
        ),
        child: _currentScreen(_selectedIndex)),
    );
  }

  @override
  void dispose() {
    context.read<MusicCubit>().stopMusic(() {});
    super.dispose();
  }
}