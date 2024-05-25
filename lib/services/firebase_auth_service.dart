import 'package:firebase_auth/firebase_auth.dart';
import 'package:tidal_wave/modules/autenticacion_usuario/classes/tw_user.dart';
import 'package:tidal_wave/services/repositories/tw_user_repository.dart';
import 'package:tidal_wave/shared/result.dart';

class FirebaseAuthService {
  
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final TWUserRepository _twUserRepository = TWUserRepository();

  static Future<Result<TWUser>> registerUser(TWUser twUser, String password) async{
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: twUser.email, password: password);
      return await _twUserRepository.addOne(twUser, userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if(e.code == "email-already-in-use"){
        return Result.error('El email proporcionado ya ha sido registrado, intente con otro.');
      }
      return Result.error('${e.code} | ${e.message}');
    }
  }

  static Future<Result<TWUser>> loginUser(String email, String password) async{
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user == null) {
        return Result.error('El usuario no se ha encontrado');
      }
      return _twUserRepository.getOne(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if(e.code == "invalid-credential"){
        return Result.error('El email ingresado no ha sido registrado, probablemente te han borrado la cuenta.');
      }
      if(e.code == "wrong-password"){
        return Result.error('La contraseña ingresada no coincide con el email proporcionado.');
      }
      return Result.error('${e.code} | ${e.message}');
    }
  }

  static Future<void> exitAccout() async{
    await _auth.signOut();
  }

  //* Mas funciones relacionados a la cuenta de usuario
}