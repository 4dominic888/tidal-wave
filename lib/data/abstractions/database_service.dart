abstract class DatabaseService<T> {
  Future<List<T>> getAll(String dataset);
  Future<T?> getOne(String dataset, String id);
  Future<void> addOne(String dataset, T data);
  Future<void> setOne(String dataset, T data, String id);
  Future<T> updateOne(String dataset, T updateData, String id);
  Future<void> deleteOne(String dataset, String id);
}