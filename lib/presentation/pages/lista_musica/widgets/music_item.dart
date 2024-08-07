import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/presentation/utils/music_state_util.dart';

class MusicItem extends StatelessWidget {

  final Music music;
  final void Function() onPlay;
  final void Function() onOptions;
  final bool? selected;

  const MusicItem({super.key, required this.music, required this.onPlay, required this.onOptions, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: selected! ? Colors.white.withOpacity(0.1) : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: selected! ? Colors.blue.shade100.withAlpha(100) : Colors.blue.shade100.withAlpha(800), width: 2),
        borderRadius: BorderRadius.circular(8.0)
      ),
      child: ListTile(
        leading: StreamBuilder<PlayerState>(
          stream: context.read<MusicCubit>().state.playerStateStream.asBroadcastStream(),
          builder: (context, snapshot) {
            //* Play/Pause
            return IconButtonUIMusic(
              borderColor: Colors.blue.shade100.withAlpha(100),
              borderSize: 2.5,
              fillColor: Colors.black.withOpacity(0.3),
              icon: selected! ? MusicStateUtil.playIcon(snapshot.data) : const Icon(Icons.play_arrow_rounded, color: Colors.white),
              onTap: selected! ? MusicStateUtil.playAction(context.read<MusicCubit>().state) : onPlay,
            );
          }
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(music.titulo, style: const TextStyle(fontWeight: FontWeight.bold))
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(music.artistasStr, style: TextStyle(color: Colors.blue.shade100, fontSize: 12))
              ),
            ),
            const SizedBox(width: 30),
            Text(music.durationString, style: TextStyle(color: Colors.blue.shade100, fontSize: 12)),
          ],
        ),
        contentPadding: const EdgeInsets.only(top: 15, bottom: 15, left: 15),
        trailing: PopupMenuButton<String>(
          color: Colors.grey.shade900,
          icon: const SizedBox(width: 35, child: Icon(Icons.more_vert)),
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            //TODO: Colocar funcionalidades luego
            const PopupMenuItem(value: 'delete', child: Text('Borrar cancion', style: TextStyle(color: Colors.white))),
            const PopupMenuItem(value: 'edit', child: Text('Editar cancion', style: TextStyle(color: Colors.white))),
            const PopupMenuItem(value: 'move', child: Text('Mover cancion', style: TextStyle(color: Colors.white))),
          ],
          onSelected: (value) {
            //* codigo
          },
        )
      ),
    );
  }
}