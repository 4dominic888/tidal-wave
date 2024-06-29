import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/models/position_data.dart';

/// Cubit para la musica escuchada actualmente
class MusicCubit extends Cubit<AudioPlayer> {

  MusicCubit() :super(AudioPlayer(
    audioLoadConfiguration: const AudioLoadConfiguration(
      //* Comenzar la carga del audio lo mas rapido posible, aunque no este cargado u optimizado
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

  Future<void> setMusic(Music music, {bool onCache = false}) async {
    await state.stop();
    if(onCache){
      await state.setAudioSource(LockCachingAudioSource(music.musica, tag: music.toAudioSource('0').sequence.first.tag));
    }
    else{
      await state.setAudioSource(music.toAudioSource(music.index.toString()), preload: true);
    }
    await state.play();
    emit(state);
  }

  Future<void> preLoadMusic(Music music) async {
    await state.setAudioSource(LockCachingAudioSource(music.musica, tag: music.toAudioSource('0').sequence.first.tag));
    await state.load();
    emit(state);
  }

  void setPlayList(List<Music> musics) async {
    await state.setAudioSource(
    ConcatenatingAudioSource(children: 
      musics.map((e) => LockCachingAudioSource(e.musica, tag: e.toAudioSource(e.index.toString()).sequence.first.tag)).toList())
    );
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

  Future<void> setClip(AudioSource audioSource, Duration moment) async {

    await state.setAudioSource(ClippingAudioSource(
        child: audioSource as UriAudioSource,
        start: moment,
        end: moment+const Duration(seconds: 5),
        duration: const Duration(seconds: 5),
        tag: audioSource.tag
    ));
  }
}