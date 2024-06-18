import 'package:tidal_wave/data/dataSources/firebase/firebase_database_service.dart';
import 'package:tidal_wave/data/repositories/database_service.dart';

enum TypeDataBase{
  /// Base de datos online en la nube, backend de google
  firestore,
  /// Base de datos local del dispositivo
  hive
}

abstract class RepositoryImplementBase<T> {
  late DatabaseService<Map<String,dynamic>> _context;

  /// Tipo de base de datos seleccionado
  TypeDataBase type;

  /// Nombre de la coleccion o tabla a hacer referencia
  String get dataset;

  /// Obtiene la instancia general de la base de datos
  DatabaseService get generalContext => _context;

  /// Accion a realizar dependiendo de la base de datos
  void actionDependingToDB({
    required void Function(FirebaseDatabaseService firestoreContext) isFireStore,
    required void Function() isHive
  }
  ){
    switch (type) {
      case TypeDataBase.firestore: {
        final context = _context as FirebaseDatabaseService;
        isFireStore.call(context);
        break;
      }

      case TypeDataBase.hive: isHive.call(); break;
      default: throw Exception('Ninguna base de datos seleccionada');
    }
  }

  RepositoryImplementBase(this.type){
    switch (type) {
      case TypeDataBase.firestore: _context = FirebaseDatabaseService(); break;
      default: throw Exception('Tipo de base de datos no valido');
    }
  }
}

mixin OnlyFirestoreAction<T> on RepositoryImplementBase<T> {
  void actionOnlyFirestore(void Function(FirebaseDatabaseService firestoreContext) action){
    switch (type) {
      case TypeDataBase.firestore: {
        final context = _context as FirebaseDatabaseService;
        action.call(context);
        break;
      }
      default: throw Exception('Esta funcion solo esta disponible para la base de datos de firebase');
    }    
  }
}