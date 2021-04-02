import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlite_workshop/models/product.dart';

class DBProvider {
  Database database;

  // CREATE DB
  Future<bool> initDB() async {
    try {
      final String databaseName = 'MYDB.database';
      final String databasePath = await getDatabasesPath();
      final String path = join(databasePath, databaseName);

      if (!await Directory(dirname(path)).exists()) {
        await Directory(dirname(path)).create(recursive: true);
      }
      database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          print('Database Create');
          String sql = "CREATE TABLE $TABLE_PRODUCT ("
              "$COLUMN_ID INTEGER PRIMARY KEY,"
              "$COLUMN_NAME TEXT,"
              "$COLUMN_PRICE REAL," //double
              "$COLUMN_STOCK INTEGER"
              ")";
          await db.execute(sql);
        },
        onUpgrade: (db, oldVersion, newVersion) {
          print('Database oldVersion: $oldVersion newVersion: $newVersion');
        },
        onOpen: (db) async {
          print("Database version: ${await db.getVersion()}");
        },
      );
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  // CLOSE DB
  Future close() async => database.close();

  // GET ALL
  Future<List<Product>> getProducts() async {
    // # v.1
    List<Map> maps = await database.query(
      TABLE_PRODUCT,
      columns: [
        COLUMN_ID,
        COLUMN_NAME,
        COLUMN_PRICE,
        COLUMN_STOCK,
      ],
    );

    // # v.2
    // List<Map> maps = await database.rawQuery("SELECT * FROM $TABLE_PRODUCT");

    if (maps.length > 0) {
      return maps.map((e) => Product.fromMap(e)).toList();
    }
    return [];
  }

  // GET
  Future<Product> getProduct(int id) async {
    // # v.1
    List<Map> maps = await database.query(
      TABLE_PRODUCT,
      columns: [
        COLUMN_ID,
        COLUMN_NAME,
        COLUMN_PRICE,
        COLUMN_STOCK,
      ],
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );

    if (maps.length > 0) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  // INSERT
  Future<Product> insertProduct(Product product) async {
    product.id = await database.insert(
      TABLE_PRODUCT,
      product.toMap(),
    );

    // # v.2
    // product.id = await database.rawInsert("INSERT Into ...");

    return product;
  }

  // UPDATE
  Future<int> updateProduct(Product product) async {
    return product.id = await database.update(
      TABLE_PRODUCT,
      product.toMap(),
      where: "$COLUMN_ID = ?",
      whereArgs: [product.id],
    );
  }

  // DELETE
  Future<int> deleteProduct(int id) async {
    return await database.delete(
      TABLE_PRODUCT,
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );
  }

  // DELETE ALL
  Future<void> deleteAllProduct() async {
    String sql = "DELETE FROM $TABLE_PRODUCT";
    return await database.rawDelete(sql);
  }
}
