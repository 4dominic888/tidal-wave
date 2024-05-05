import 'package:flutter/material.dart';
import 'package:tidal_wave/modules/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';

class MusicItem extends StatefulWidget {

  final Music music;

  const MusicItem({super.key, required this.music});

  @override
  State<MusicItem> createState() => _MusicItemState();
}

class _MusicItemState extends State<MusicItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue.shade100.withAlpha(100), width: 2),
        borderRadius: BorderRadius.circular(8.0)
      ),
      child: ListTile(
        leading: IconButtonUIMusic(
          borderColor: Colors.blue.shade100.withAlpha(100),
          borderSize: 2.5,
          fillColor: Colors.black.withOpacity(0.3),
          icon: const Icon(Icons.play_arrow_rounded, size: 25, color: Colors.white),
          onTap: () {},                  
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(widget.music.titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(widget.music.artista, style: TextStyle(color: Colors.blue.shade100, fontSize: 12))
              ),
            ),
            const SizedBox(width: 30),
            Text(widget.music.durationString, style: TextStyle(color: Colors.blue.shade100, fontSize: 12)),
          ],
        ),
        contentPadding: const EdgeInsets.only(top: 15, bottom: 15, left: 15),
        trailing: SizedBox(
          width: 40,
          child: IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert, color: Colors.white))),
      ),
    );
  }
}