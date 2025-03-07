import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../model_view/MaterialProvider.dart';
import '../model/materialModel.dart';
import '../utils/helper/pdf_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void>? _materialsFuture;

  @override
  void initState() {
    super.initState();
    _materialsFuture =
        Provider.of<MaterialProvider>(context, listen: false).loadMaterials();
  }

  Future<void> _showEditDialog(MaterialModel material) async {
    final nameController = TextEditingController(text: material.name);
    final quantityController = TextEditingController(text: material.quantity);
    final supplierController = TextEditingController(text: material.supplier);

    DateTime selectedDate = material.deliveryDate;
    TimeOfDay selectedTime = TimeOfDay(
      hour: material.deliveryDate.hour,
      minute: material.deliveryDate.minute,
    );

    final dateController =
        TextEditingController(text: DateFormat.yMd().format(selectedDate));
    final timeController =
        TextEditingController(text: selectedTime.format(context));

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Edit Material"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Material Name"),
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: "Quantity & Unit"),
                  ),
                  TextField(
                    controller: supplierController,
                    decoration: InputDecoration(labelText: "Supplier"),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: "Delivery Date",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                          dateController.text =
                              DateFormat.yMd().format(selectedDate);
                        });
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: "Delivery Time",
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                          timeController.text = selectedTime.format(context);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime newDeliveryDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  MaterialModel updatedMaterial = MaterialModel(
                    id: material.id,
                    name: nameController.text,
                    quantity: quantityController.text,
                    supplier: supplierController.text,
                    deliveryDate: newDeliveryDate,
                  );
                  await Provider.of<MaterialProvider>(context, listen: false)
                      .updateMaterial(updatedMaterial);
                  setState(() {});
                  Navigator.pop(context);
                },
                child: Text("Update"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final materialProvider = Provider.of<MaterialProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Site Material Tracker"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () async {
              final pdfFile =
                  await PDFHelper.generatePDF(materialProvider.materials);
              PDFHelper.sharePDF(pdfFile);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _materialsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (materialProvider.materials.isEmpty) {
            return Center(
              child: Text(
                "No materials added.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              itemCount: materialProvider.materials.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final material = materialProvider.materials[index];
                String formattedDate =
                    DateFormat.yMd().add_jm().format(material.deliveryDate);
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Icon(Icons.inventory, color: Colors.deepPurple),
                    title: Text(
                      material.name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Qty: ${material.quantity}"),
                          Text("Supplier: ${material.supplier}"),
                          SizedBox(height: 4),
                          Text(
                            "Delivery: $formattedDate",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () async {
                            await _showEditDialog(material);
                            setState(() {
                              _materialsFuture =
                                  materialProvider.loadMaterials();
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            await materialProvider.deleteMaterial(material.id!);
                            setState(() {
                              _materialsFuture =
                                  materialProvider.loadMaterials();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pushNamed('Entry_screen').then((_) {
            setState(() {
              _materialsFuture = materialProvider.loadMaterials();
            });
          });
        },
      ),
    );
  }
}
