import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/materialModel.dart';
import '../model_view/MaterialProvider.dart';

class EntryScreen extends StatefulWidget {
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Material"),
        leading: Container(),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Material Name"),
                ),
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: "Quantity & Unit"),
                ),
                TextFormField(
                  controller: supplierController,
                  decoration: InputDecoration(labelText: "Supplier"),
                ),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Delivery Date",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _selectDate,
                ),
                TextFormField(
                  controller: timeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Delivery Time",
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: _selectTime,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text("Save"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedDate == null || selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select both date and time"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      DateTime deliveryDate = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );

                      final newMaterial = MaterialModel(
                        name: nameController.text,
                        quantity: quantityController.text,
                        supplier: supplierController.text,
                        deliveryDate: deliveryDate,
                      );
                      Provider.of<MaterialProvider>(context, listen: false)
                          .addMaterial(newMaterial);
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
