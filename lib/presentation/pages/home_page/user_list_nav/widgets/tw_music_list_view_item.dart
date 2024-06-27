import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tidal_wave/domain/models/music_list.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_list_manager_use_case.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/screens/lista_musica_screen.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';

// final _musicManagerUseCase = GetIt.I<MusicManagerUseCase>();
final _musicListManagerUseCase = GetIt.I<MusicListManagerUseCase>();

class TWMusicListViewItem extends StatelessWidget {
  const TWMusicListViewItem({
    super.key,
    required this.item,
  });

  final MusicList item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final musicListResult = await _musicListManagerUseCase.obtenerLista(item.id);
          if(!context.mounted) return;
          if(!musicListResult.onSuccess){
            showDialog(context: context, builder: (context) => PopupMessage(
              title: 'Error',
              description: musicListResult.errorMessage!
            ));
            return;
          }
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListaMusicaScreen(listado: musicListResult.data!.musics!)));
        },
        splashColor: Colors.white,
        child: Card(
          color: Colors.grey.withOpacity(0.4),
          child: Container(
            height: 110,
            padding: const EdgeInsets.all(0),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: item.image != null ? 
                        Image.file(File.fromUri(item.image!)).image : 
                        Image.asset('assets/placeholder/music-placeholder.png').image,
                        fit: BoxFit.cover
                      )
                    ),
                  )
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 10,
                  child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(item.name, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
                        ),
                        Text('${item.musics!.length} canciones', style: TextStyle(color: Colors.grey.shade200)),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 10.0, top: 4.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(item.description, style: TextStyle(color: Colors.grey.shade400, fontSize: 13), textAlign: TextAlign.justify,)
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
