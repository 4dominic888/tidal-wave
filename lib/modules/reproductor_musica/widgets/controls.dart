import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:tidal_wave/modules/reproductor_musica/widgets/volume_control.dart';
import 'package:tidal_wave/shared/music_state_util.dart';

class Controls extends StatefulWidget {
  final AudioPlayer audioPlayer;
  static const int seconds = 10;
  final Color color;


  const Controls({super.key, required this.audioPlayer, required this.color});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  Widget _buttonBuilder(Icon icon, double size, void Function() onPressed, {bool locked = false}){
    return IconButton(
      icon: icon,
      color: locked ? widget.color.withOpacity(0.3) : widget.color,
      iconSize: size,
      onPressed: onPressed,
      enableFeedback: true
    );
  }

  Future<void> seekRewind() async{
    await widget.audioPlayer.seek(widget.audioPlayer.position - const Duration(seconds: Controls.seconds));
  }

  Future<void> seekForward() async{
    await widget.audioPlayer.seek(widget.audioPlayer.position + const Duration(seconds: Controls.seconds));
  }

  Future<void> restart() async {
    await widget.audioPlayer.seek(Duration.zero);
  }

  Future<void> random() async {
    final random = Random();
    final int maxIndex = widget.audioPlayer.sequence!.length;
    final int randomIndex = random.nextInt(maxIndex);
    await widget.audioPlayer.seek(Duration.zero, index: min(randomIndex, maxIndex));

  }  

  final _superToolTipController = SuperTooltipController();

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
              audioPlayer: widget.audioPlayer,
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
              stream: widget.audioPlayer.currentIndexStream,
              builder: (context, snapshot) {
                return MusicStateUtil.previousReturns<Widget>(snapshot.data,
                  noActive: _buttonBuilder(const Icon(Icons.skip_previous_rounded), 60, (){}, locked: true),
                  active: _buttonBuilder(const Icon(Icons.skip_previous_rounded), 60, widget.audioPlayer.seekToPrevious)
                );
              })
            ),
            
            //* Play/Stop
            StreamBuilder<PlayerState>(
              stream: widget.audioPlayer.playerStateStream,
              builder: (context, snapshot) => _buttonBuilder(MusicStateUtil.playIcon(snapshot.data), 80, MusicStateUtil.playAction(widget.audioPlayer))
            ),
        
            //* Skip button
            Expanded(
              child: StreamBuilder<int?>(
              stream: widget.audioPlayer.currentIndexStream,
              builder: (context, snapshot) {
                return MusicStateUtil.nextReturns<Widget>(
                  snapshot.data,
                  widget.audioPlayer,
                  noActive: _buttonBuilder(const Icon(Icons.skip_next_rounded), 60, (){}, locked: true),
                  active: _buttonBuilder(const Icon(Icons.skip_next_rounded), 60, widget.audioPlayer.seekToNext)
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

  @override
  void dispose() {
    _superToolTipController.dispose();
    super.dispose();
  }
}