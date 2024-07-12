import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_list_manager_use_case.dart';
import 'package:tidal_wave/presentation/pages/home_page/user_account_nav/screens/create_user_list_screen.dart';
import 'package:tidal_wave/presentation/pages/home_page/user_list_nav/widgets/tw_music_list_view_item.dart';

class UserListNav extends StatefulWidget {
  const UserListNav({super.key});

  @override
  State<UserListNav> createState() => _UserListNavState();
}

class _UserListNavState extends State<UserListNav> {

  final _playListManagerUseCase = GetIt.I<MusicListManagerUseCase>();

  Future<List<MusicList>>? _listOfMusicList() async {
    final result = await _playListManagerUseCase.obtenerListasLocales();
    if(result.onSuccess){
      return result.data!.toList();
    }
    throw Exception(result.errorMessage);
  }

  Widget _userMusicList() {
    return Expanded(
      child: Column(
        children: [

          //* Boton para crear nueva lista
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateUserListScreen())),
                splashColor: Colors.white.withOpacity(0.68),
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  color: Colors.grey.shade900.withOpacity(0.9),
                  child: DottedBorder(
                    color: Colors.grey.shade400,
                    strokeCap: StrokeCap.butt,
                    strokeWidth: 2,
                    dashPattern: const [10,5],
                    child: const ListTile(
                      leading: Icon(Icons.add),
                      title: Text('Nueva Lista'),
                    )
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<MusicList>>(
              future: _listOfMusicList(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if(snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
                if(snapshot.data!.isEmpty) return const Center(child: Text('No hay listas creadas'));
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return TWMusicListViewItem(
                      item: item,
                      isOnline: false,
                      onDelete: () => setState(() {}),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 30),

        _userMusicList()
      ],
    );
  }
}