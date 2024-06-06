import 'package:cloud_firestore/cloud_firestore.dart';

class FireBaseDatabaseService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<Map<String,dynamic>>> getAll(String collectionName, [bool Function(Map<String, dynamic>)? where, int limit = 10]) async{
    final query = await db.collection(collectionName).limit(limit).get();
    return query.docs.map((d) => d.data()).where(where ?? (_) => true).toList();
  }

  Future<Map<String, dynamic>?> getOne(String collectionName, String id) async{
      final query = await db.collection(collectionName).doc(id).get();
      return query.data();
  }

  Future<void> addOne(String collectionName, Map<String, dynamic> data) async{
    await db.collection(collectionName).add(data);
  }

  Future<void> setOne(String collectionName, Map<String, dynamic> data, String id) async{
    await db.collection(collectionName).doc(id).set(data);
  }

  Future<Map<String, dynamic>> updateOne(String collectionName, Map<String, dynamic> updateData, String id) async{
    await db.collection(collectionName).doc(id).update(updateData);
    return updateData;
  }

  Future<void> deleteOne(String collectionName, String id) async{
    await getOne(collectionName, id);
    await db.collection(collectionName).doc(id).delete();
  }
}