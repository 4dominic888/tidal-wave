enum DataSourceType{
  local,
  online
}

DataSourceType getDataSourceTypeByString(String type){
  switch (type) {
    case 'DataSourceType.local': return DataSourceType.local;
    case 'DataSourceType.online': return DataSourceType.online;
    default: throw ArgumentError('Estado desconocido: $type');
  }
}