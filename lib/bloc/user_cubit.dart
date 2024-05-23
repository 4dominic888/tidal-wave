import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tidal_wave/modules/autenticacion_usuario/classes/tw_user.dart';

class UserCubit extends Cubit<TWUser?>{
  UserCubit() : super(null);

  set user(TWUser user) => emit(user);

}