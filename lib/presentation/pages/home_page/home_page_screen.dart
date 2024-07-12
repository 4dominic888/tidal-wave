import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tidal_wave/domain/use_case/interfaces/authentication_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/presentation/bloc/music_playing_cubit.dart';
import 'package:tidal_wave/presentation/bloc/user_cubit.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/mini_music_player.dart';
import 'package:tidal_wave/presentation/pages/home_page/user_account_nav/screens/tw_account_nav.dart';
import 'package:tidal_wave/presentation/pages/home_page/find_music_nav/screens/tw_find_nav.dart';
import 'package:tidal_wave/presentation/pages/home_page/home_nav/screens/tw_home_nav.dart';
import 'package:tidal_wave/presentation/pages/home_page/user_list_nav/screens/user_list_nav.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _authenticationUseCase = GetIt.I<AuthenticationManagerUseCase>();


  int _selectedIndex = 0;

  Widget _currentScreen(int index){
    switch (index) {
      case 0: return const TWHomeNav();
      case 1: return const TWFindNav();
      case 2: return const UserListNav();
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

  @override
  Widget build(BuildContext context) {

    FirebaseAuth.instance.authStateChanges().listen((user) async => await validateAndGetUser());

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
      body: Stack(
        children: [
          Container(
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
            child: _currentScreen(_selectedIndex)
          ),

          //* Mini reproductor de musica
          BlocBuilder<MusicPlayingCubit, bool>(
            bloc: GetIt.I<MusicPlayingCubit>(),
            builder: (context, state) {
              return AnimatedPositioned(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInBack,
                bottom: state ? 0 : -90,
                width: MediaQuery.of(context).size.width,
                height: 90,
                child: const MiniMusicPlayer()
              );
            }
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    context.read<MusicCubit>().stopMusic();
    super.dispose();
  }
}