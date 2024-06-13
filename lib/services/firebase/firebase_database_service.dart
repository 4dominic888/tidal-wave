import 'package:cloud_firestore/cloud_firestore.dart';

class FireBaseDatabaseService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getSubCollection(String collectionName, [List<String> queryArray = const []]){
    if(queryArray.length % 2 != 0) throw ArgumentError('queryArray debe tener longitud par');
    dynamic retorno = db.collection(collectionName);
    int iterator = 0;
    while (iterator != queryArray.length) {
      retorno = (retorno as CollectionReference<Map<String, dynamic>>).doc(queryArray[iterator]);
      iterator++;
      retorno = (retorno as DocumentReference<Map<String, dynamic>>).collection(queryArray[iterator]);
      retorno++;
    }
    return retorno;
  }

  Future<List<Map<String,dynamic>>> getAll(String collectionName, [List<String> queryArray = const [], bool Function(Map<String, dynamic>)? where, int limit = 10]) async{
    final query = await _getSubCollection(collectionName, queryArray).limit(limit).get();
    return query.docs.map((d) => d.data()..addAll({"uuid": d.id})).where(where ?? (_) => true).toList();
  }

  Future<Map<String, dynamic>?> getOne(String collectionName, String id, [List<String> queryArray = const []]) async{
    final query = await _getSubCollection(collectionName, queryArray).doc(id).get();
    return query.data()?..addAll({"uuid": query.id});
  }

  Future<void> addOne(String collectionName, Map<String, dynamic> data, [List<String> queryArray = const []]) async{
    await _getSubCollection(collectionName, queryArray).add(data);
  }

  Future<void> setOne(String collectionName, Map<String, dynamic> data, String id, [List<String> queryArray = const []]) async{
    await _getSubCollection(collectionName, queryArray).doc(id).set(data);
  }

  Future<Map<String, dynamic>> updateOne(String collectionName, Map<String, dynamic> updateData, String id, [List<String> queryArray = const []]) async{
    await _getSubCollection(collectionName, queryArray).doc(id).update(updateData);
    return updateData;
  }

  Future<void> deleteOne(String collectionName, String id, [List<String> queryArray = const []]) async{
    await _getSubCollection(collectionName, queryArray).doc(id).delete();
  }
}