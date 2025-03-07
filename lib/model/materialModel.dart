class MaterialModel {
  int? id;
  String name;
  String quantity;
  String supplier;
  DateTime deliveryDate;

  MaterialModel({
    this.id,
    required this.name,
    required this.quantity,
    required this.supplier,
    required this.deliveryDate,
  });

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(map['deliveryDate']);
    } catch (e) {
      parsedDate = DateTime.now();
    }
    return MaterialModel(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      supplier: map['supplier'],
      deliveryDate: parsedDate,
    );
  }
}
