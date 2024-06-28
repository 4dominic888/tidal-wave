/// enum para definir el tipo de fuente
/// 
/// `local` es para recursos que fueron creadas locales, no estan en la base de datos de la nube
/// 
/// `online` es para recursos que estan en la base de datos en la nube
/// 
/// `fromOnline` es para recursos que fueron sacados de manera online pero que ahora son locales
enum DataSourceType{
  local,
  online,
  fromOnline,
}

/// Casteador de `String` a `DataSourceType`
DataSourceType getDataSourceTypeByString(String type){
  switch (type) {
    case 'DataSourceType.local': return DataSourceType.local;
    case 'DataSourceType.online': return DataSourceType.online;
    case 'DataSourceType.fromOnline' : return DataSourceType.fromOnline;
    default: throw ArgumentError('Estado desconocido: $type');
  }
}