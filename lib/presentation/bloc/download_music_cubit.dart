import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidal_wave/data/abstractions/save_file_local.dart';

class DownloadMusicCubit extends Cubit<Map<String, StreamController<ProgressOfDownloadData>>>{
  DownloadMusicCubit() : super({});

  void addDownloadElement(String id){
    state.addAll({id:StreamController<ProgressOfDownloadData>.broadcast()});
    emit(state);
  }

  void removeDownloadElement(String id){  
    state.removeWhere((key, value) => key == id);
    emit(state);
  }

  void addProgressOfDownload(String id, ProgressOfDownloadData progress){
    state[id]!.add(progress);
    emit(state);
  }

  Future<void> closeStreamController(String id) async{
    await state[id]!.close();
    emit(state);
  }

  bool existDownloadElement(String id){
    return state.containsKey(id);
  }

  Stream<ProgressOfDownloadData> getStream(String id){
    return state[id]!.stream.asBroadcastStream();
  }
}