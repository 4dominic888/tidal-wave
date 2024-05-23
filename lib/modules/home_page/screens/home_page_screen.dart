import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/modules/autenticacion_usuario/screens/login_screen.dart';
import 'package:tidal_wave/modules/autenticacion_usuario/screens/register_screen.dart';
import 'package:tidal_wave/modules/home_page/screens/tw_account_nav.dart';
import 'package:tidal_wave/modules/home_page/screens/tw_home_nav.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/tw_drawer.dart';

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

  @override
  Widget build(BuildContext context) {
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
        drawer: TWDrawer(options: [
          {"Iniciar sesion": (){
            context.read<MusicCubit>().stopMusic(()=>setState((){}));
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
          }},
          {"Registrarse": () {
            context.read<MusicCubit>().stopMusic(()=>setState((){}));
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
          }
          },
        ]),
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