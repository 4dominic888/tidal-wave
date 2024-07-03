import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tidal_wave/data/abstractions/database_service.dart';
import 'package:tidal_wave/data/utils/find_firebase.dart';

class FirestoreDatabaseService extends DatabaseService<Map<String, dynamic>>{
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Future<void> init() async {
    db.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  @override
  Future<List<Map<String,dynamic>>> getAll(String dataset, [List<String> queryArray = const [], FindManyFieldsToOneSearchFirebase? finder, int? timestamp, int limit = 10]) async{
    var basicQuery = _getSubCollection(dataset, queryArray).orderBy('upload_at', descending: true);
    //* Apply where
    if(finder != null && finder.find != null && finder.find.toString().isNotEmpty){
      basicQuery = basicQuery.where(finder.field, isGreaterThanOrEqualTo: finder.find);
      basicQuery = basicQuery.where(finder.field, isLessThanOrEqualTo: finder.find);
    }

    final query = timestamp != null ? 
      await basicQuery.startAfter([timestamp]).limit(limit).get() :
      await basicQuery.limit(limit).get();

    if(query.docs.isEmpty) return [];
    return query.docs.map((d) => d.data()..addAll({"uuid": d.id})).toList();
  }

  @override
  Future<Map<String, dynamic>?> getOne(String dataset, String id, [List<String> queryArray = const []]) async{
    final query = await _getSubCollection(dataset, queryArray).doc(id).get();
    return query.data()?..addAll({"uuid": query.id});
  }

  /// Metodo auxiliar para obtener colecciones de las colecciones de manera recursiva segun el queryArray.
  /// 
  /// Por ejemplo 
  /// ```
  /// // Query Array
  /// [DocumentoX, ColeccionY, DocumentoY, ColeccionZ]
  /// 
  /// // Coleccion resultante en Firestore
  /// "dataset/DocumentoX/ColeccionY/DocumentY/ColeccionZ"
  /// ````
  /// Siempre debe ser par la coleccion o arrojara un `ArgumentError`.
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

  /// Este metodo sirve para obtener los datos de un array de referencias y devolver los datos respectivo en un `List<Map<String, dynamic>>` (o JSON).
  /// 
  /// Si la referencia no existe en firestore, simplemente las omitira.
  Future<List<Map<String,dynamic>>> getAllByReferences(List<DocumentReference> references) async{
    var returnList = <Map<String,dynamic>>[];
    for (int i = 0; i < references.length; i++) {
      final temp = await getOneByReference(references[i]);
      if(temp == null) continue;
      returnList.add(temp);
    }
    return returnList;
  }

  /// Obtiene el dato de una referencia como `List<Map<String, dynamic>>` (o JSON).
  /// 
  /// Puede devolver datos nulos si la referencia no existe.
  Future<Map<String, dynamic>?> getOneByReference(DocumentReference reference) async{
    final query = await db.doc(reference.path).get();
    return query.data()!..addAll({"uuid": query.id});
  }


  /// Agrega un elemento a un campo de tipo array en un especifico documento.
  /// 
  /// `dataset` es la coleccion principal.
  /// 
  /// `docId` es para especificar la id del documento.
  /// 
  /// `arrayName` es el nombre del campo de array.
  /// 
  /// `item` es el dato a agregar
  /// 
  /// Si el documento no existe, lanzara un error.
  /// 
  /// Si el campo no existe o su valor es null, se crea de manera vacia para colocar el elemento.
  Future<void> addElementToArray<T>(String dataset, String docId, String arrayName, T item) async {
    final documentReference = db.collection(dataset).doc(docId);
    final doc = await documentReference.get();

    if(doc.exists){
      //* Establece el campo en un array si fuera nulo
      if(doc.data()![arrayName] == null){
        await documentReference.set({arrayName: []}, SetOptions(merge: true, ));
      }
      await documentReference.update({
        arrayName : (doc.data()![arrayName] as List<T>)..add(item)
      });
      return;
    }
    throw Exception('El documento no existe');
  }

  /// Establece una lista de elementos al array seleccionado
  /// 
  /// `dataset` es la coleccion principal.
  /// 
  /// `docId` es para especificar la id del documento.
  /// 
  /// `arrayName` es el nombre del campo de array.
  /// 
  /// `items` son los datos a agregar
  /// 
  /// Si el documento no existe, lanzara un error.
  /// 
  /// Si el campo no existe o su valor es null, se crea de manera vacia para colocar el elemento.
  Future<void> setElementsToArray<T>(String dataset, String docId, String arrayName, List<T> items) async {
    final documentReference = db.collection(dataset).doc(docId);
    final doc = await documentReference.get();

    if(doc.data()![arrayName] == null){
      documentReference.set({arrayName: items}, SetOptions());
      return;
    }

    if(doc.exists){
      documentReference.update({
        arrayName: items
      });
      return;
    }
    throw Exception('El documento no existe');
  }

  /// Elimina elementos del array de un documento
  /// 
  /// `dataset` es la coleccion principal.
  /// 
  /// `docId` es para especificar la id del documento.
  /// 
  /// `arrayName` es el nombre del campo de array.
  /// 
  /// `item` es el dato a eliminar
  /// 
  /// Si el documento no existe, no hace nada.
  /// 
  /// Si el campo no existe o su valor es null, se crea de manera vacia solamente.
  Future<void> removeElementToArray<T>(String dataset, String docId, String arrayName, T item) async {
    final documentReference = db.collection(dataset).doc(docId);
    final doc = await documentReference.get();
    if(doc.exists){
      if(doc.data()![arrayName] == null){
        documentReference.set({arrayName: []});
        return;
      }

      documentReference.update({
        arrayName : (doc.data()![arrayName] as List<DocumentReference>)..remove(item)
      });
    }
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
  Future<void> updateOne(String dataset, Map<String, dynamic> updateData, String id, [List<String> queryArray = const []]) async{
    await _getSubCollection(dataset, queryArray).doc(id).update(updateData);
  }

  @override
  Future<void> deleteOne(String dataset, String id, [List<String> queryArray = const []]) async{
    await _getSubCollection(dataset, queryArray).doc(id).delete();
  }
}