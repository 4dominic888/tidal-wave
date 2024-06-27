import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:group_button/group_button.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_list_manager_use_case.dart';
import 'package:tidal_wave/presentation/pages/home_page/user_account_nav/screens/create_user_list_screen.dart';
import 'package:tidal_wave/presentation/pages/home_page/user_list_nav/widgets/tw_music_list_view_item.dart';

class TWUserListNav extends StatefulWidget {
  const TWUserListNav({super.key});

  @override
  State<TWUserListNav> createState() => _TWUserListNavState();
}

class _TWUserListNavState extends State<TWUserListNav> {

  final _playListManagerUseCase = GetIt.I<MusicListManagerUseCase>();
  static final _buttonsController = GroupButtonController(selectedIndex: 0);
  static final _buttonsOptions = ['Mis listas', 'Otras listas'];

  Future<List<MusicList>>? _listOfMusic() async {
    final result = await _playListManagerUseCase.obtenerListasLocales();
    if(result.onSuccess){return result.data!.toList();}
    throw Exception(result.errorMessage);
  }

  Widget _userMusicList() {
    return Expanded(
      child: Column(
        children: [
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
              future: _listOfMusic(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if(snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
                if(snapshot.data == null && snapshot.data!.isEmpty) return const Center(child: Text('No hay listas creadas'));
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return TWMusicListViewItem(item: item);
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  final Widget _otherUserLists = const Center(
    child: Icon(Icons.list),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        //* Seleccionar entre 2 opciones
        GroupButton(
          controller: _buttonsController,
          buttonIndexedBuilder: (selected, index, context) => ElevatedButton(
            onPressed: (){
              setState(() {
                _buttonsController.selectIndex(index);
              });
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateColor.resolveWith((states) => selected ? const Color.fromARGB(255, 36, 161, 196) : const Color.fromARGB(255, 20, 84, 101))
            ),
            child: Text(_buttonsOptions[index], style: TextStyle(color: selected ? Colors.white : Colors.grey.shade300))
          ),
          isRadio: true,
          buttons: _buttonsOptions
        ),

        const SizedBox(height: 10),

        if(_buttonsController.selectedIndex == 0) _userMusicList()
        else _otherUserLists

      ],
    );
  }
}