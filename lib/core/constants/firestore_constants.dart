class FirestoreConstants {
  // Colecciones
  static const String usersCollection = 'users';
  static const String mesasCollection = 'mesas';
  static const String pedidosCollection = 'pedidos';
  static const String productosCollection = 'productos';
  static const String transaccionesCollection = 'transacciones';

  // Campos comunes
  static const String idField = 'id';
  static const String nameField = 'name';
  static const String emailField = 'email';
  static const String roleField = 'role';
  static const String estadoField = 'estado';
  static const String totalField = 'total';
  static const String dateField = 'date';

  // Campos específicos de pedidos
  static const String clienteField = 'cliente';
  static const String itemsField = 'items';

  // Campos específicos de productos
  static const String descripcionField = 'descripcion';
  static const String priceField = 'price';
  static const String categoryField = 'category';
  static const String stockField = 'stock';
  static const String imageUrlField = 'imageUrl';

  // Campos específicos de mesas
  static const String capacidadField = 'capacidad';
  static const String necesitaServicioField = 'necesitaServicio';
}
