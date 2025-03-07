import 'package:flutter/material.dart';

import '../model/materialModel.dart';
import '../utils/helper/databaseHelper.dart';

class MaterialProvider extends ChangeNotifier {
  List<MaterialModel> _materials = [];
  List<MaterialModel> get materials => _materials;

  Future<void> loadMaterials() async {
    _materials = await DatabaseHelper.dbHelper.getMaterials();
    notifyListeners();
  }

  Future<void> addMaterial(MaterialModel material) async {
    await DatabaseHelper.dbHelper.insertMaterial(material);
    await loadMaterials();
  }

  Future<void> deleteMaterial(int id) async {
    await DatabaseHelper.dbHelper.deleteMaterial(id);
    await loadMaterials();
  }

  Future<void> updateMaterial(MaterialModel material) async {
    await DatabaseHelper.dbHelper.updateMaterial(material);
    await loadMaterials();
  }
}
