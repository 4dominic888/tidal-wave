import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;
  static const int seconds = 10;
  const Controls({super.key, required this.audioPlayer});

  Widget _buttonBuilder(Icon icon, double size, void Function() onPressed){
    return IconButton(
      icon: icon,
      color: Colors.white,
      iconSize: size,
      onPressed: onPressed
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
          return const Icon(Icons.play_arrow_rounded, size: 80, color: Colors.white);
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //* Rewind button
        Expanded(child: _buttonBuilder(const Icon(Icons.fast_rewind_rounded), 60, seekRewind)),

        //* Previous button
        Expanded(child: _buttonBuilder(const Icon(Icons.skip_previous_rounded), 60, audioPlayer.seekToPrevious)),
        _playButton(),

        //* Previous button
        Expanded(child: _buttonBuilder(const Icon(Icons.skip_next_rounded), 60, audioPlayer.seekToNext)),

        //* Rewind button
        Expanded(child: _buttonBuilder(const Icon(Icons.fast_forward_rounded), 60, seekForward)),
      ],
    );
  }
}