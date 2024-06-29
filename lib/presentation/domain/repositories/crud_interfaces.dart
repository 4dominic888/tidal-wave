import 'package:tidal_wave/data/result.dart';

abstract class Addable<T> {
  Future<Result<T>> addOne(T data, [String? id]);
}

abstract class GetAllable<T>{
  Future<Result<List<T>>> getAll();
}

abstract class GetOneable<T>{
  Future<Result<T>> getOne(String id);
}

abstract class Updatable<T>{
  Future<Result<bool>> updateOne(T data, String id);
}

abstract class Deletable{
  Future<Result<String>> deleteOne(String id);
}
