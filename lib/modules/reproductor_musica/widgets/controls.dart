import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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
      enableFeedback: true
    );
  }

  Widget _playButton(){
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if(!(playing ?? false)){
          return _buttonBuilder(const Icon(Icons.play_arrow_rounded), 80, audioPlayer.play);
        }
        else if(processingState != ProcessingState.completed){
          return _buttonBuilder(const Icon(Icons.pause_rounded), 80, audioPlayer.pause);
        }
        else{
          return Icon(Icons.play_arrow_rounded, size: 80, color: color);
        }
      },
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
            Container(child: _buttonBuilder(const Icon(Icons.shuffle_rounded), 30, random))
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
              stream: audioPlayer.currentIndexStream,
              builder: (context, snapshot) {
                if ((snapshot.data ?? 0) == 0) {
                  return _buttonBuilder(const Icon(Icons.skip_previous_rounded), 60, (){}, locked: true);
                }
                return _buttonBuilder(const Icon(Icons.skip_previous_rounded), 60, audioPlayer.seekToPrevious);
              }
            )),
            
            _playButton(),
        
            //* Skip button
            Expanded(child: StreamBuilder<int?>(
              stream: audioPlayer.currentIndexStream,
              builder: (context, snapshot) {
                if ((snapshot.data ?? 0) == (audioPlayer.sequence?.length ?? 0)-1) {
                  return _buttonBuilder(const Icon(Icons.skip_next_rounded), 60, (){}, locked: true);  
                }
                return _buttonBuilder(const Icon(Icons.skip_next_rounded), 60, audioPlayer.seekToNext);
              }
            )),
        
            //* Forward button
            Expanded(child: _buttonBuilder(const Icon(Icons.fast_forward_rounded), 60, seekForward)),
          ],
        ),
      ],
    );
  }
}