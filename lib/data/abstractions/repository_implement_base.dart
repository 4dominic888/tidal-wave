import 'package:tidal_wave/data/dataSources/firebase/firestore_database_service.dart';
import 'package:tidal_wave/data/abstractions/database_service.dart';
import 'package:tidal_wave/data/dataSources/sqflite/sqflite_database_service.dart';

abstract class RepositoryImplementBase {
  /// Obtiene la instancia general de la base de datos
  final DatabaseService<Map<String,dynamic>> _onlineContext;
  final DatabaseService<Map<String,dynamic>> _offlineContext;

  DatabaseService<Map<String,dynamic>> get onlineContext => _onlineContext;
  DatabaseService<Map<String,dynamic>> get offlineContext => _offlineContext;

  /// Nombre de la coleccion o tabla a hacer referencia
  String get dataset;

  RepositoryImplementBase({
    required DatabaseService<Map<String,dynamic>> onlineContext,
    required DatabaseService<Map<String,dynamic>> offlineContext
  }) : _onlineContext = onlineContext, _offlineContext = offlineContext;
}

mixin UseFirestore on RepositoryImplementBase{
  FirestoreDatabaseService get onlinefirestoreContext => _onlineContext as FirestoreDatabaseService;
  
}

mixin UseSqflite on RepositoryImplementBase{
  SqfliteDatabaseService get offlinesqfliteContext => _offlineContext as SqfliteDatabaseService;
}

