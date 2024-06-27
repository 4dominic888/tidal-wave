import 'package:tidal_wave/data/dataSources/firebase/firestore_database_service.dart';
import 'package:tidal_wave/data/abstractions/database_service.dart';
import 'package:tidal_wave/data/dataSources/sqflite/sqflite_database_service.dart';

abstract class RepositoryImplementBase {
  /// Obtiene la instancia general de la base de datos
  late final DatabaseService<Map<String,dynamic>> context;

  /// Nombre de la coleccion o tabla a hacer referencia
  String get dataset;

  RepositoryImplementBase({required DatabaseService<Map<String,dynamic>> databaseService}) : context = databaseService;
}

mixin UseFirestore on RepositoryImplementBase{
  FirestoreDatabaseService get firestoreContext => context as FirestoreDatabaseService;
}

mixin UseSqflite on RepositoryImplementBase{
  SqfliteDatabaseService get sqfliteContext => context as SqfliteDatabaseService;
}

