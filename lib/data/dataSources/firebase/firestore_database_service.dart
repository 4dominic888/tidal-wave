import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tidal_wave/data/repositories/database_service.dart';

class FirestoreDatabaseService extends DatabaseService<Map<String, dynamic>>{
  final FirebaseFirestore db = FirebaseFirestore.instance;


  @override
  Future<List<Map<String,dynamic>>> getAll(String dataset, [List<String> queryArray = const [], bool Function(Map<String, dynamic>)? where, int limit = 10]) async{
    final query = await _getSubCollection(dataset, queryArray).limit(limit).get();
    if(query.docs.isEmpty) return [];
    return query.docs.map((d) => d.data()..addAll({"uuid": d.id})).where(where ?? (_) => true).toList();
  }

  @override
  Future<Map<String, dynamic>?> getOne(String dataset, String id, [List<String> queryArray = const []]) async{
    final query = await _getSubCollection(dataset, queryArray).doc(id).get();
    return query.data()?..addAll({"uuid": query.id});
  }

  CollectionReference<Map<String, dynamic>> _getSubCollection(String dataset, [List<String> queryArray = const []]){
    if(queryArray.length % 2 != 0) throw ArgumentError('queryArray debe tener longitud par');
    dynamic retorno = db.collection(dataset);
    int iterator = 0;
    while (iterator != queryArray.length) {
      retorno = (retorno as CollectionReference<Map<String, dynamic>>).doc(queryArray[iterator]);
      iterator++;
      retorno = (retorno as DocumentReference<Map<String, dynamic>>).collection(queryArray[iterator]);
      iterator++;
    }
    return retorno;
  }

  Future<List<Map<String,dynamic>>> getAllByReferences(List<DocumentReference> references) async{
    var returnList = <Map<String,dynamic>>[];
    for (int i = 0; i < references.length; i++) {
      final temp = await getOneByReference(references[i]);
      if(temp == null) continue;
      returnList.add(temp);
    }
    return returnList;
  }

  Future<Map<String, dynamic>?> getOneByReference(DocumentReference reference) async{
    final query = await db.doc(reference.path).get();
    return query.data()!..addAll({"uuid": query.id});
  }

  @override
  Future<void> addOne(String dataset, Map<String, dynamic> data, [List<String> queryArray = const []]) async{
    await _getSubCollection(dataset, queryArray).add(data);
  }

  @override
  Future<void> setOne(String dataset, Map<String, dynamic> data, String id, [List<String> queryArray = const []]) async{
    await _getSubCollection(dataset, queryArray).doc(id).set(data);
  }

  @override
  Future<Map<String, dynamic>> updateOne(String dataset, Map<String, dynamic> updateData, String id, [List<String> queryArray = const []]) async{
    await _getSubCollection(dataset, queryArray).doc(id).update(updateData);
    return updateData;
  }

  @override
  Future<void> deleteOne(String dataset, String id, [List<String> queryArray = const []]) async{
    await _getSubCollection(dataset, queryArray).doc(id).delete();
  }
}