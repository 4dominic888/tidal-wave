import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/tw_user.dart';

abstract class AuthenticationManagerUseCase{
  Future<Result<TWUser>> registrarse(TWUser usuario, String password);
  Future<Result<TWUser>> iniciarSesion(String email, String password);
  Future<Result<String>> actualizarInformacionUsuario(TWUser nuevoUsuario);
  Future<Result<TWUser>> obtenerUsuarioActual();
  Future<void> salirDeLaCuenta();
}