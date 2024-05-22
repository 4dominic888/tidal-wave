import 'package:firebase_auth/firebase_auth.dart';
import 'package:tidal_wave/modules/autenticacion_usuario/classes/tw_user.dart';
import 'package:tidal_wave/services/repositories/tw_user_repository.dart';
import 'package:tidal_wave/shared/result.dart';

class FirebaseAuthService {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TWUserRepository _twUserRepository = TWUserRepository();

  Future<Result<TWUser>> registerUser(TWUser twUser, String password) async{
    try {
      await _auth.createUserWithEmailAndPassword(email: twUser.email, password: password);
      return await _twUserRepository.addOne(twUser);
    } on FirebaseAuthException catch (e) {
      return Result.error('some error ocurrer: ${e.code}');
    }
  }

  Future<Result<TWUser>> loginUser(TWUser twUser, String password) async{
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: twUser.email, password: password);
      if (credential.user == null) {
        return Result.error('El usuario no se ha encontrado');
      }
      return _twUserRepository.getOne(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return Result.error('some error ocurrer: ${e.code}');
    }
  }

  //* Mas funciones relacionados a la cuenta de usuario
}