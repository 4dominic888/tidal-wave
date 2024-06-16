import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:tidal_wave/shared/music_state_util.dart';

class VolumeControl extends StatefulWidget {

  final AudioPlayer audioPlayer;
  final Widget Function(Icon icon, double size, void Function() onPressed, {bool locked}) buttonBuilder;

  const VolumeControl({super.key, required this.audioPlayer, required this.buttonBuilder});

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {

  final _superToolTipController = SuperTooltipController();

  @override
  Widget build(BuildContext context) {
    return SuperTooltip(
      showBarrier: true,
      controller: _superToolTipController,
      popupDirection: TooltipDirection.up,
      content: StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            width: 50,
            height: 200,
            child: SfSlider.vertical(
              activeColor: Colors.red,
              min: 0.0,
              max: 1.0,
              value: widget.audioPlayer.volume,
              onChanged: (value) {
                setState(() {
                  widget.audioPlayer.setVolume(value);
                });
              },
            ),
          );
        }
      ),
      child: StreamBuilder<double>(
        stream: widget.audioPlayer.volumeStream.asBroadcastStream(),
        builder: (context, snapshot) {
          return Container(child: widget.buttonBuilder(MusicStateUtil.volumeIcon(snapshot.data), 30, () async {
            await _superToolTipController.showTooltip();
          }));
        }
      )
    );
  }

  @override
  void dispose() {
    _superToolTipController.dispose();
    super.dispose();
  }
}