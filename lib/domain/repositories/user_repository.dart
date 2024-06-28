import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/models/tw_user.dart';
import 'package:tidal_wave/domain/repositories/crud_interfaces.dart';

typedef T = TWUser;

abstract class UserRepository implements Addable<T>, GetOneable<T>, GetAllable<T>, Updatable<T>, Deletable{
  
  @override
  Future<Result<List<T>>> getAll();

  @override
  Future<Result<T>> getOne(String id);

  @override
  Future<Result<T>> addOne(T data, [String? id]);

  @override
  Future<Result<bool>> updateOne(T data, String id);

  @override
  Future<Result<String>> deleteOne(String id);
  
  Future<Result<T>> getLocalUser();
}