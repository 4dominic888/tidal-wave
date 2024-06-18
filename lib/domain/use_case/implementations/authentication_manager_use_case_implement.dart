import 'package:tidal_wave/data/dataSources/firebase/firebase_auth_service.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/tw_user.dart';
import 'package:tidal_wave/domain/repositories/user_repository.dart';
import 'package:tidal_wave/domain/use_case/interfaces/authentication_manager_use_case.dart';

class AuthenticationManagerUseCaseImplement extends AuthenticationManagerUseCase{
  
  final UserRepository repo;
  final FirebaseAuthService _auth;

  AuthenticationManagerUseCaseImplement(this.repo) : _auth = FirebaseAuthService(repo);

  @override
  Future<Result<TWUser>> iniciarSesion(String email, String password) async {
    return await _auth.loginUser(email, password);
  }

  @override
  Future<Result<String>> actualizarInformacionUsuario(TWUser nuevoUsuario) async {
    return await _auth.updateNormalInfo(nuevoUsuario);
  }


  @override
  Future<Result<TWUser>> registrarse(TWUser usuario, String password) async {
    return await _auth.registerUser(usuario, password);
  }

  @override
  Future<void> salirDeLaCuenta() async => await _auth.exitAccout();
  
  @override
  Future<Result<TWUser>> obtenerUsuarioActual() async {
    return  await _auth.getCurrentUser();
  }

}