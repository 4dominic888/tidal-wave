import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:tidal_wave/modules/home_page/classes/music_list.dart';
import 'package:tidal_wave/modules/home_page/screens/create_user_list_screen.dart';
import 'package:tidal_wave/modules/home_page/widgets/tw_music_list_view_item.dart';

class TWUserList extends StatefulWidget {
  const TWUserList({super.key});

  @override
  State<TWUserList> createState() => _TWUserListState();
}

class _TWUserListState extends State<TWUserList> {

  static final _buttonsController = GroupButtonController(selectedIndex: 0);
  static final _buttonsOptions = ['Mis listas', 'Otras listas'];
  final _finalListTest = <MusicList>[];

  Widget _userList() => Expanded(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateUserListScreen())),
              splashColor: Colors.white,
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
                    titleTextStyle: TextStyle(color: Colors.white),
                    iconColor: Colors.white,
                    leading: Icon(Icons.add),
                    title: Text('Nueva Lista'),
                  )
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.vertical,
            itemCount: _finalListTest.length,
            itemBuilder: (context, index) {
              final item = _finalListTest[index];
              return TWMusicListViewItem(item: item);
            },
          ),
        ),
      ],
    ),
  );

  final Widget _otherUserLists = const Center(
    child: Icon(Icons.list, color: Colors.white,),
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

        if(_buttonsController.selectedIndex == 0) _userList()
        else _otherUserLists

      ],
    );
  }
}