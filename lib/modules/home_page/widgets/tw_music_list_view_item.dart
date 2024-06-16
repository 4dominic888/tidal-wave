import 'package:flutter/material.dart';
import 'package:tidal_wave/modules/home_page/classes/music_list.dart';
import 'package:tidal_wave/modules/lista_musica/screens/lista_musica_screen.dart';
import 'package:tidal_wave/services/repositories/tw_music_repository.dart';
import 'package:tidal_wave/shared/widgets/popup_message.dart';

class TWMusicListViewItem extends StatelessWidget {
  const TWMusicListViewItem({
    super.key,
    required this.item,
  });

  final MusicList item;

  IconData typeIcon(String type){
    switch (type) {
      case 'public-list': return Icons.public;
      case 'private-list': return Icons.lock;
      case 'offline-list': return Icons.visibility_off;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final result = await TWMusicRepository().getAllByReferences(item.musics);
          if(!context.mounted) return;
          if(!context.mounted) return;
          if(!result.onSuccess){
            showDialog(context: context, builder: (context) => PopupMessage(
              title: 'Error',
              description: result.errorMessage!
            ));
            return;
          }
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListaMusicaScreen(listado: result.data!)));
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
                        image: item.image != null ? Image.network(item.image.toString()).image : Image.asset('assets/placeholder/music-placeholder.png').image,
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
                          child: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold))
                        ),
                        Icon(typeIcon(item.type), color: Colors.white, size: 15),
                        Text('${item.musics.length} canciones', style: TextStyle(color: Colors.grey.shade200)),
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
