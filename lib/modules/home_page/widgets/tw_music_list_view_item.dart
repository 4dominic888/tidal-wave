import 'package:flutter/material.dart';
import 'package:tidal_wave/modules/home_page/classes/music_list.dart';

class TWMusicListViewItem extends StatelessWidget {
  const TWMusicListViewItem({
    super.key,
    required this.item,
  });

  final MusicList item;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.withOpacity(0.4),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(image: 
                    NetworkImage('https://firebasestorage.googleapis.com/v0/b/tidal-wave-service.appspot.com/o/music-thumb%2Fi-3d4f492b-a80d-4235-8985-09f3c648cbe1?alt=media&token=02dd6ad8-255a-43fd-b8cc-01c7a54c44fa'),
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
                    Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold)),
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
            ),
            Expanded(
              flex: 4,
              child: IconButton(onPressed: (){}, icon: const Icon(Icons.play_arrow, color: Colors.white))
            )
          ],
        ),
      ),
    );
  }
}
