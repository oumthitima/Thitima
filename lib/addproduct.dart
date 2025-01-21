import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ShowProduct.dart';
import 'Showproducttype.dart';
import 'showproductgrid.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        useMaterial3: true,
      ),
      home: AddProduct(),
    );
  }
}

class AddProduct extends StatefulWidget {
  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController productidController = TextEditingController();
  final categories = ['Electronics', 'Clothing', 'Food', 'Books'];
  String? selectedCategory;

  int _selectedRadio = 0;
  String _selectedOption = '';
  Map<int, String> radioOptions = {
    1: 'ให้ส่วนลด',
    2: 'ไม่ให้ส่วนลด',
  };

  DateTime? productionDate;

  Future<void> pickProductionDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: productionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        productionDate = pickedDate;
        dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> saveProductToDatabase() async {
    try {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref('products');
      Map<String, dynamic> productData = {
        'name': nameController.text,
        'description': desController.text,
        'category': selectedCategory,
        'productionDate': productionDate?.toIso8601String(),
        'price': double.parse(priceController.text),
        'quantity': int.parse(quantityController.text),
        'discountOption': _selectedOption,
      };
      await dbRef.push().set(productData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowProduct(),
        ),
      );

      _formKey.currentState?.reset();
      nameController.clear();
      desController.clear();
      priceController.clear();
      quantityController.clear();
      dateController.clear();
      setState(() {
        selectedCategory = null;
        productionDate = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เพิ่มข้อมูลสินค้า',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 165, 233, 246),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ข้อมูลสินค้า',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: nameController,
                  label: 'ชื่อสินค้า',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อสินค้า';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: desController,
                  label: 'รายละเอียดสินค้า',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรายละเอียดสินค้า';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: _inputDecoration('ประเภทสินค้า'),
                  items: categories
                      .map((category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedCategory = value),
                  validator: (value) {
                    if (value == null) return 'กรุณาเลือกประเภทสินค้า';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: dateController,
                  label: 'วันที่ผลิต',
                  readOnly: true,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => pickProductionDate(context),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: priceController,
                  label: 'ราคาสินค้า',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกราคาสินค้า';
                    }
                    if (double.tryParse(value) == null) {
                      return 'กรุณากรอกราคาเป็นตัวเลข';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: quantityController,
                  label: 'จำนวนสินค้า',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกจำนวนสินค้า';
                    }
                    if (int.tryParse(value) == null) {
                      return 'กรุณากรอกจำนวนเป็นตัวเลข';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'ตัวเลือกส่วนลด',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Column(
                  children: radioOptions.entries.map((entry) {
                    return RadioListTile<int>(
                      title: Text(entry.value),
                      value: entry.key,
                      groupValue: _selectedRadio,
                      onChanged: (value) {
                        setState(() {
                          _selectedRadio = value!;
                          _selectedOption = entry.value;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveProductToDatabase();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 238, 167, 167),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'บันทึกสินค้า',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool readOnly = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    );
  }
}
