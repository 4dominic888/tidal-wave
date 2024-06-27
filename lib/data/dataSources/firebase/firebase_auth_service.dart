import 'package:firebase_auth/firebase_auth.dart';
import 'package:tidal_wave/domain/models/tw_user.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/repositories/user_repository.dart';

class FirebaseAuthService {
  
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository userRepository;

  FirebaseAuthService(this.userRepository);

  Future<Result<TWUser>> registerUser(TWUser twUser, String password) async{
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: twUser.email, password: password);
      return await userRepository.addOne(twUser, userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if(e.code == "email-already-in-use"){
        return Result.error('El email proporcionado ya ha sido registrado, intente con otro.');
      }
      return Result.error('${e.code} | ${e.message}');
    }
  }

  Future<Result<TWUser>> loginUser(String email, String password) async{
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user == null) {
        return Result.error('El usuario no se ha encontrado');
      }
      return userRepository.getOne(credential.user!.uid);
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

  Future<void> exitAccout() async{
    await _auth.signOut();
  }

  Future<Result<String>> updateNormalInfo(TWUser newUser) async {
    try {
      final Result<bool> result = await userRepository.updateOne(newUser, _auth.currentUser!.uid);
      if(!result.onSuccess) throw Exception(result.errorMessage);
      return Result.success('Se han actualizado sus datos con exito');
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<Result<TWUser>> getCurrentUser() async {
    try {
      final userUid = _auth.currentUser?.uid;
      if (userUid != null) {
        return await userRepository.getOne(userUid);
      }
      return Result.error('No se ha podido obtener la informacion del usuario');
    } catch (e) {return Result.error(e.toString());}
  }

  Future<void> deleteUser() async{
    await _auth.currentUser!.delete();
  }

  Future<void> updateEmail(String newEmail) async{
    await _auth.currentUser!.verifyBeforeUpdateEmail(newEmail);
  }

}