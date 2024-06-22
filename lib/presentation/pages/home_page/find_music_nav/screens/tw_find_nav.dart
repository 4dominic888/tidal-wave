import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';
import 'package:tidal_wave/presentation/pages/home_page/find_music_nav/widgets/music_element_view.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/text_field_find.dart';
import 'package:tidal_wave/domain/models/music.dart';

class TWFindNav extends StatefulWidget {
  const TWFindNav({super.key});

  @override
  State<TWFindNav> createState() => _TWFindNavState();
}


class _TWFindNavState extends State<TWFindNav> {

  final _musicManagerUseCase = GetIt.I<MusicManagerUseCase>();
  String? selectUUID;

  void _findMusic(String query){
    setState(() {
      // _list = widget.listado.where((element) {
      //   if (value.trim().isEmpty) {
      //     return true;
      //   }
      //   return element.titulo.toLowerCase().contains(value.toLowerCase().trim()) ||
      //         element.artistasStr.toLowerCase().contains(value.toLowerCase().trim());

      // }).toList();      
    });
  }

  Future<List<Music>> listOfMusic() async {
    final result = await _musicManagerUseCase.obtenerCancionesPublicas();
    if(result.onSuccess){return result.data!.toList();}
    throw Exception(result.errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          actions: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFieldFind(
                  hintText:'Buscar cancion...',
                  suffixIcon: IconButtonUIMusic(
                    borderColor: Colors.blue.shade400.withAlpha(50),
                    borderSize: 2.0,
                    fillColor: Colors.transparent,
                    icon: const Icon(Icons.search, size: 25),
                    onTap: () {},
                  ),
                  onChanged: _findMusic
                ),
              )
            ),
          ],
        ),
    
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
    
        FutureBuilder<List<Music>>(
          future: listOfMusic(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));}
            if(snapshot.hasError) {return SliverToBoxAdapter(child: Center(child: Text('Ha ocurrido un error ${snapshot.error.toString()}')));}
            return StatefulBuilder(
              builder: (context, setState) {
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1
                  ),
                  delegate: SliverChildBuilderDelegate(childCount: snapshot.data!.length, (context, index) {
                    final item = snapshot.data![index];
                    return Builder(
                      builder: (context) {
                        return MusicElementView(
                          item: item,
                          selected: [item.uuid == selectUUID],
                          onPlay: () {
                            selectUUID = item.uuid;
                            setState(() {});
                          },
                        );
                      }
                    );
                  }),
                );
              }
            );
          }
        )
      ],
    );
  }
}
