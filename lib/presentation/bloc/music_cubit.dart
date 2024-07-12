import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/domain/models/music.dart';
import 'package:tidal_wave/domain/models/position_data.dart';
import 'package:tidal_wave/presentation/bloc/music_playing_cubit.dart';
import 'package:tidal_wave/presentation/bloc/play_list_state_cubit.dart';

/// Cubit para la musica escuchada actualmente
class MusicCubit extends Cubit<AudioPlayer> {

  String? idSelected;
  DataSourceType? dataSourceTypeSelected;
  final _playingCubit = GetIt.I<MusicPlayingCubit>();
  final _playListStateCubit = GetIt.I<PlayListStateCubit>();

  MusicCubit() : super(_initAudioPlayer){
    //* Listeners
    state.currentIndexStream.listen((event) {
      if (event == null) { _playListStateCubit.clear(); }
      else { _playListStateCubit.setIndex(event); }
    });
  }

  static final AudioPlayer _initAudioPlayer = AudioPlayer(
    audioLoadConfiguration: const AudioLoadConfiguration(
      //* Comenzar la carga del audio lo mas rapido posible, aunque no este cargado u optimizado
      androidLoadControl: AndroidLoadControl(prioritizeTimeOverSizeThresholds: true)
    )
  );

  Stream<PositionData> get positionDataStream {
    final audioPlayer = state;
    return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      audioPlayer.positionStream, audioPlayer.bufferedPositionStream, audioPlayer.durationStream,
      (p, b, d) => PositionData(p, b, d ?? Duration.zero)
    );
  }

  void enableLoop() async {
    await state.setLoopMode(LoopMode.all);
  }
  
  void disableLoop() async {
    await state.setLoopMode(LoopMode.off);
  }

  Future<void> setMusic(Music? music, {bool onCache = false}) async {
    GetIt.I<PlayListStateCubit>().clear();
    idSelected = music?.uuid;
    dataSourceTypeSelected = music?.type;
    await state.stop();
    if(music == null){
      _playingCubit.desactive();
      state.setAudioSource(ConcatenatingAudioSource(children: []));
      emit(_initAudioPlayer);
      return;
    }
    _playingCubit.active();
    if(onCache){
      await state.setAudioSource(LockCachingAudioSource(music.musica, tag: music.toAudioSource('0').sequence.first.tag));
    }
    else{
      await state.setAudioSource(music.toAudioSource(music.index.toString()), preload: true);
    }
    await state.play();
    emit(state);
  }

  Future<void> setPlayList(List<Music> musics) async {
    await state.setAudioSource(
    ConcatenatingAudioSource(children: 
      musics.map((e) => e.toAudioSource(e.index.toString())).toList())
    );
    await state.stop();
    emit(state);
  }

  Future<void> seekTo(int? index) async{
    _playingCubit.active();
    await state.seek(Duration.zero, index: index);
  }

  Future<void> stopMusic() async {
    idSelected = null;
    dataSourceTypeSelected = null;
    _playingCubit.desactive();
    await state.stop();
    await state.seek(null, index: -1);
    emit(state);
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