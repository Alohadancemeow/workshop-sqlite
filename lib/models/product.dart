const String TABLE_PRODUCT = 'product';
const String COLUMN_ID = 'id';
const String COLUMN_NAME = 'name';
const String COLUMN_PRICE = 'price';
const String COLUMN_STOCK = 'stock';

class Product {
  int id;
  String name;
  double price;
  int stock;

  Product();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_NAME: name,
      COLUMN_PRICE: price,
      COLUMN_STOCK: stock,
    };

    if (id != null) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  Product.fromMap(Map<String, dynamic> map) {
    id = map[COLUMN_ID];
    name = map[COLUMN_NAME];
    price = map[COLUMN_PRICE];
    stock = map[COLUMN_STOCK];
  }

  @override
  String toString() => '$id, $name, $price, $stock';
}
