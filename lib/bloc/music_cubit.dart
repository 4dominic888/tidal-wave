import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/position_data.dart';

/// Cubit para la musica escuchada actualmente
class MusicCubit extends Cubit<AudioPlayer> {

  MusicCubit() :super(AudioPlayer());

  Stream<PositionData> get positionDataStream {
    final audioPlayer = state;
    return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      audioPlayer.positionStream, audioPlayer.bufferedPositionStream, audioPlayer.durationStream,
      (p, b, d) => PositionData(p, b, d ?? Duration.zero)
    );
  }
  bool isActive = false;

  void enableLoop() async {
    await state.setLoopMode(LoopMode.all);
  }
  
  void disableLoop() async {
    await state.setLoopMode(LoopMode.off);
  }

  void setMusic(AudioSource audioSource) async {
    await state.stop();
    await state.setAudioSource(audioSource, preload: false);
    await state.play();
    emit(state);
  }

  void setPlayList(ConcatenatingAudioSource playList) async {
    await state.setAudioSource(playList);
    emit(state);
  }

  void seekTo(int? index) async{
    await state.seek(Duration.zero, index: index);
  }

  void stopMusic(void Function()? toEnd){
    if (isActive) {
      state.stop();
      state.seek(null, index: -1);
      isActive = false;
      toEnd?.call();
    }
  }
}