import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/presentation/pages/reproductor_musica/widgets/volume_control.dart';
import 'package:tidal_wave/shared/music_state_util.dart';

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;
  static const int seconds = 10;
  final Color color;

  const Controls({super.key, required this.audioPlayer, required this.color});

  Widget _buttonBuilder(Icon icon, double size, void Function() onPressed, {bool locked = false}){
    return IconButton(
      icon: icon,
      color: locked ? color.withOpacity(0.3) : color,
      iconSize: size,
      onPressed: onPressed,
    );
  }

  Future<void> seekRewind() async{
    await audioPlayer.seek(audioPlayer.position - const Duration(seconds: seconds));
  }

  Future<void> seekForward() async{
    await audioPlayer.seek(audioPlayer.position + const Duration(seconds: seconds));
  }

  Future<void> restart() async {
    await audioPlayer.seek(Duration.zero);
  }

  Future<void> random() async {
    final random = Random();
    final int maxIndex = audioPlayer.sequence!.length;
    final int randomIndex = random.nextInt(maxIndex);
    await audioPlayer.seek(Duration.zero, index: min(randomIndex, maxIndex));

  }  

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(child: _buttonBuilder(const Icon(Icons.replay_rounded), 30, restart)),
            Expanded(
              child: Container(),
            ),
            Container(child: _buttonBuilder(const Icon(Icons.shuffle_rounded), 30, random)),

            // Volumen
            VolumeControl(
              audioPlayer: audioPlayer,
              buttonBuilder: _buttonBuilder,
            ),
            
          ]
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //* Rewind button
            Expanded(child: _buttonBuilder(const Icon(Icons.fast_rewind_rounded), 60, seekRewind)),
        
            //* Previous button
            Expanded(child: StreamBuilder<int?>(
              stream: audioPlayer.currentIndexStream.asBroadcastStream(),
              builder: (context, snapshot) {
                return MusicStateUtil.previousReturns<Widget>(snapshot.data,
                  noActive: _buttonBuilder(const Icon(Icons.skip_previous_rounded), 60, (){}, locked: true),
                  active: _buttonBuilder(const Icon(Icons.skip_previous_rounded), 60, audioPlayer.seekToPrevious)
                );
              })
            ),
            
            //* Play/Stop
            StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream.asBroadcastStream(),
              builder: (context, snapshot) { 
                return _ButtonBuilder(
                  icon: MusicStateUtil.playIcon(snapshot.data),
                  color: color,
                  size: 80,
                  onPressed: MusicStateUtil.playAction(audioPlayer)
                );
              }
            ),
        
            //* Skip button
            Expanded(
              child: StreamBuilder<int?>(
              stream: audioPlayer.currentIndexStream.asBroadcastStream(),
              builder: (context, snapshot) {
                return MusicStateUtil.nextReturns<Widget>(
                  snapshot.data,
                  audioPlayer,
                  noActive: _buttonBuilder(const Icon(Icons.skip_next_rounded), 60, (){}, locked: true),
                  active: _buttonBuilder(const Icon(Icons.skip_next_rounded), 60, audioPlayer.seekToNext)
                );
              })
            ),
        
            //* Forward button
            Expanded(child: _buttonBuilder(const Icon(Icons.fast_forward_rounded), 60, seekForward)),
          ],
        ),
      ],
    );
  }
}

class _ButtonBuilder extends StatelessWidget {

  final Icon icon;
  final bool? locked = false;
  final Color color;
  final double size;
  final void Function()? onPressed;

  const _ButtonBuilder({required this.icon, required this.color, required this.size, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      color: locked! ? color.withOpacity(0.3) : color,
      iconSize: size,
      onPressed: onPressed,
    );
  }
}