import 'package:flutter_bloc/flutter_bloc.dart';

/*
  {
    'id-lista': [current index list] Only One Register
  }
*/

/// Cubit para guardar el estado de las musicas reproduciendose actualmente en alguna lista
class PlayListStateCubit extends Cubit<Map<String, int>>{
  PlayListStateCubit() : super({});

  bool isOnList({required String listId, required int index}) {
    return state[listId] == index;
  }

  void playingMusicOnAList({required String listId, required int index}){
    state.clear();
    state.addAll({ listId: index });
    emit(Map.from(state));
  }

  void nextIndex(){
    state[state.keys.first] = state.values.first+1;
  }
  
  void previousIndex(){
    state[state.keys.first] = state.values.first-1;
  }  

  int? getId({required String listId}){
    return state[listId];
  }

  void clear(){
    state.clear();
    emit({});
  }
}