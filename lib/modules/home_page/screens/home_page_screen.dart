import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidal_wave/bloc/user_cubit.dart';
import 'package:tidal_wave/modules/autenticacion_usuario/screens/login_screen.dart';
import 'package:tidal_wave/modules/autenticacion_usuario/screens/register_screen.dart';
import 'package:tidal_wave/modules/home_page/screens/tw_account_nav.dart';
import 'package:tidal_wave/modules/home_page/screens/tw_home_nav.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/tw_drawer.dart';
import 'package:tidal_wave/modules/subir_musica/screens/upload_music_screen.dart';
import 'package:tidal_wave/services/repositories/tw_user_repository.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  int _selectedIndex = 0;

  Widget _currentScreen(int index){
    switch (index) {
      case 0: return const TWHomeNav();
      case 1: return const Center(child: Icon(Icons.search));
      case 2: return const Center(child: Icon(Icons.library_music));
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

  final List<Map<String, void Function()>> _drawerOptions = [];

  @override
  Widget build(BuildContext context) {

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
      setState(() {});
    });

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
        { "Sube tu canción": () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadMusicScreen())) },
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
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey.shade900.withOpacity(0.6),
        toolbarHeight: 0,
        elevation: 0,
      ),
        drawer: TWDrawer(options: _drawerOptions),
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
}