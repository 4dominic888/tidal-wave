/// Clase abstracta que sirve como guia para mapear bases de datos.
abstract class DatabaseService<T> {

  /// Se inicializa principales configuraciones u operaciones de gran importancia para usar el servicio.
  Future<void> init();

  /// Obtiene todos los registros segun el `dataset`.
  Future<List<T>> getAll(String dataset);

  /// Obtiene un registro en especifico segun el `dataset` y la `id`.
  Future<T?> getOne(String dataset, String id);

  /// Agrega un elemento segun el tipo de dato en `data` y el `dataset` a agregar.
  /// 
  /// La ID es autogenerada.
  Future<void> addOne(String dataset, T data);

  /// Establece un elemento segun el tipo de dato en `data`, el `dataset` a agregar y la `id` que tendra el elemento.
  Future<void> setOne(String dataset, T data, String id);

  /// Actualiza un elemento por otro nuevo en base a la `id` del viejo elemento.
  Future<void> updateOne(String dataset, T updateData, String id);

  /// Elimina un elemento segun la `id` y `dataset` colocado.
  Future<void> deleteOne(String dataset, String id);

  // Cierra la conexion
  Future<void> close() async {
    //
  }
}