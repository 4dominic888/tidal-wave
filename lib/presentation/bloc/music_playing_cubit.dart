import 'package:flutter_bloc/flutter_bloc.dart';

class MusicPlayingCubit extends Cubit<bool> {
  MusicPlayingCubit() : super(false);

  void active(){
    emit(true);
  }

  void desactive(){
    emit(false);
  }

  bool get isActive => state;
}