class Result<T> {
  final T? _data;
  final bool _onSuccess;
  final String? _errorMessage;

  T? get data => _data;
  bool get onSuccess => _onSuccess;
  String? get errorMessage => _errorMessage;

  Result.sucess(T data) : _data=data,  _onSuccess=true, _errorMessage=null;
  Result.error(String errorMessage) : _data=null, _onSuccess=false, _errorMessage=errorMessage;

}