import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tidal_wave/data/abstractions/database_service.dart';
import 'package:uuid/uuid.dart';

class SqfliteDatabaseService extends DatabaseService<Map<String, dynamic>>{

  static late Database? _db;
  Database get db => _db!;
  static const String dbName = 'tw_local_database.db';

  @override
  Future<void> init() async {
    if(_db != null) return;
    
    final Directory documentDirectory = await getApplicationDocumentsDirectory();
    _db = await openDatabase(join(documentDirectory.path, dbName), onCreate: (db, version) async {
      //* Creando tablas para los datos a guardar localmente, como musicas y listas.
      final String createScript = await rootBundle.loadString('assets/raw_queries/create_tables.sql');
      await db.execute(createScript);
    });
  }

  @override
  Future<void> addOne(String dataset, Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    await _db!.insert(dataset, data..addAll({'uuid': uuid}));
  }

  @override
  Future<void> setOne(String dataset, Map<String, dynamic> data, String id) async {
    await _db!.insert(dataset, data..addAll({'uuid': id}), conflictAlgorithm: ConflictAlgorithm.replace);
  }  

  @override
  Future<List<Map<String, dynamic>>> getAll(String dataset, {String? where, List<String>? whereArgs, int? limit}) async {
    return await _db!.query(dataset, limit: limit, where: where, whereArgs: whereArgs);
  }
  
  @override
  Future<Map<String, dynamic>?> getOne(String dataset, String id) async {
    final element = await _db!.query(dataset, where: 'uuid = ?', whereArgs: [id]);
    if(element.isEmpty) return null;
    return element.first;
  }

  /// Solo funciona para tablas que relacionan 2 tablas de muchos a muchos
  /// 
  /// El Map solo tomara solo la primera clave valor.
  Future<void> addManytoMany(String dataset, Map<String, String> dataReference1, Map<String, String> dataReference2) async {
    await _db!.insert(dataset, {...dataReference1,...dataReference2});
  }

  @override
  Future<void> updateOne(String dataset, Map<String, dynamic> updateData, String id) async {
    await _db!.update(dataset, updateData, where: 'uuid = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteOne(String dataset, String id) async {
    await _db!.delete(dataset, where: 'uuid = ?', whereArgs: [id]);
  }
  
  @override
  Future<void> close() async {
    await _db!.close();
  }
}