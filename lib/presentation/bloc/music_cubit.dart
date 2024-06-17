import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tidal_wave/domain/models/position_data.dart';
import 'package:tidal_wave/presentation/utils/function_utils.dart';

/// Cubit para la musica escuchada actualmente
class MusicCubit extends Cubit<AudioPlayer> {

  MusicCubit() :super(AudioPlayer(
    audioLoadConfiguration: const AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(prioritizeTimeOverSizeThresholds: true)
    )
  ));

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

  Future<void> setClip(String origin, Duration moment) async {
    if(isURL(origin)) { 
      await state.setUrl(origin);
    }
    else {
      await state.setFilePath(origin);
    }
    await state.setClip(start: moment, end: moment+const Duration(seconds: 5));
  }
}