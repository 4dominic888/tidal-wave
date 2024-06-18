import 'package:tidal_wave/data/dataSources/firebase/firestore_database_service.dart';
import 'package:tidal_wave/data/repositories/database_service.dart';

abstract class RepositoryImplementBase {
  late final DatabaseService<Map<String,dynamic>> _context;

  /// Obtiene la instancia general de la base de datos
  DatabaseService get context => _context;

  /// Nombre de la coleccion o tabla a hacer referencia
  String get dataset;

  RepositoryImplementBase(DatabaseService<Map<String,dynamic>> context) :  _context = context;
  RepositoryImplementBase.firestore() : _context = FirestoreDatabaseService();
}

mixin UseFirestore on RepositoryImplementBase{
  FirestoreDatabaseService get firestoreContext => context as FirestoreDatabaseService;
}
