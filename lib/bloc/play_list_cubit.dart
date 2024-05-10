import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';

class PlayListCubit extends Cubit<ConcatenatingAudioSource>{
  PlayListCubit() : super(ConcatenatingAudioSource(children: []));

  ConcatenatingAudioSource setPlayList(List<Music> list){
    emit(ConcatenatingAudioSource(children: list.map((e) => e.toAudioSource(e.index.toString())).toList()));
    return state;
  }

}