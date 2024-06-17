import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Clase para cambiar poder cambiar el estado de un icon o funcion en base al estado de la musica
class MusicStateUtil {
  static T playReturns<T>(PlayerState? playerState, {required T playCase, required T stopCase, required T playStatic}){
    final processingState = playerState?.processingState;
    final playing = playerState?.playing;

    if(!(playing ?? false)){
      return playCase;
    }
    else if(processingState != ProcessingState.completed){
      return stopCase;
    }
    else{
      return playStatic;
    }
  }

  static T previousReturns<T>(int? currentIndex, {required T active, required T noActive}){
    if ((currentIndex ?? 0) == 0) {
      return noActive;
    }
    return active;
  }

  static T nextReturns<T>(int? currentIndex, AudioPlayer audioPlayer, {required T active, required T noActive}){
    if ((currentIndex ?? 0) == (audioPlayer.sequence?.length ?? 0)-1) {
      return noActive;
    }
    return active;
  }

  static Icon playIcon(PlayerState? playerState, {Color? color}){
    return playReturns<Icon>(playerState, 
      playCase: Icon(Icons.play_arrow_rounded, color: color),
      stopCase: Icon(Icons.pause, color: color),
      playStatic: Icon(Icons.play_arrow_rounded, color: color)
    );
  }

  static void Function() playAction(AudioPlayer audioPlayer){
    return playReturns<void Function()>(audioPlayer.playerState, 
      playCase: audioPlayer.play,
      stopCase: audioPlayer.stop,
      playStatic: () {},
    );
  }

  static Icon volumeIcon(double? volume){

    if (volume == null) {
      return const Icon(Icons.volume_off_rounded);
    }

    if (volume > 0.5) {
      return const Icon(Icons.volume_up_rounded);
    } else if(volume <= 0.5 && volume > 0) {
      return const Icon(Icons.volume_down_rounded);
    }
    else if(volume <= 0){
      return const Icon(Icons.volume_mute_rounded);
    }
    else{
      return const Icon(Icons.volume_off_rounded);
    }
  }
}