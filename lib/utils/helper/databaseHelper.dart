import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../model/materialModel.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static DatabaseHelper dbHelper = DatabaseHelper._();
  Database? db;

  Future<void> initDB() async {
    String path = join(await getDatabasesPath(), 'material.db');
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE materials (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            quantity TEXT,
            supplier TEXT,
            deliveryDate TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertMaterial(MaterialModel material) async {
    if (db == null) {
      await initDB();
    }
    return await db!.rawInsert(
      'INSERT INTO materials (name, quantity, supplier, deliveryDate) VALUES (?, ?, ?, ?)',
      [
        material.name,
        material.quantity,
        material.supplier,
        material.deliveryDate.toIso8601String(),
      ],
    );
  }

  Future<List<MaterialModel>> getMaterials() async {
    if (db == null) {
      await initDB();
    }
    List<Map<String, dynamic>> all =
        await db!.rawQuery("SELECT * FROM materials");
    return all.map((map) => MaterialModel.fromMap(map)).toList();
  }

  Future<int> deleteMaterial(int id) async {
    if (db == null) {
      await initDB();
    }
    return await db!.rawDelete('DELETE FROM materials WHERE id = ?', [id]);
  }

  Future<int> updateMaterial(MaterialModel material) async {
    if (db == null) {
      await initDB();
    }
    return await db!.rawUpdate(
      'UPDATE materials SET name = ?, quantity = ?, supplier = ?, deliveryDate = ? WHERE id = ?',
      [
        material.name,
        material.quantity,
        material.supplier,
        material.deliveryDate.toIso8601String(),
        material.id,
      ],
    );
  }
}
