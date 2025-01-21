import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; // สำหรับ intl package
import 'ProductDetail.dart'; // หน้ารายละเอียดสินค้า

class ShowFilterType extends StatefulWidget {
  final String category;

  ShowFilterType({required this.category});

  @override
  _ShowFilterTypeState createState() => _ShowFilterTypeState();
}

class _ShowFilterTypeState extends State<ShowFilterType> {
  late DatabaseReference _productRef;
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _productRef = FirebaseDatabase.instance.ref('products');
    _fetchProducts();
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd-MMMM-yyyy').format(parsedDate);
  }

  Future<void> _fetchProducts() async {
    try {
      DataSnapshot snapshot = await _productRef.get();
      if (snapshot.exists) {
        final List<Map<String, dynamic>> allProducts = [];
        final productsData = snapshot.value as Map<dynamic, dynamic>;

        productsData.forEach((key, value) {
          allProducts.add({
            'id': key,
            'name': value['name'],
            'category': value['category'],
            'price': value['price'],
            'quantity': value['quantity'],
            'description': value['description'],
            'productionDate': value['productionDate'],
          });
        });

        setState(() {
          _filteredProducts = allProducts
              .where((product) => product['category'] == widget.category)
              .toList();
        });
      } else {
        print('No data available.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // ฟังก์ชันแสดง AlertDialog เพื่อแก้ไขข้อมูลสินค้า
  void showEditDialog(String productId, Map<String, dynamic> productData) {
    TextEditingController nameController =
        TextEditingController(text: productData['name']);
    TextEditingController descriptionController =
        TextEditingController(text: productData['description']);
    TextEditingController categoryController =
        TextEditingController(text: productData['category']);
    TextEditingController quantityController =
        TextEditingController(text: productData['quantity'].toString());
    TextEditingController priceController =
        TextEditingController(text: productData['price'].toString());
    TextEditingController productionDateController =
        TextEditingController(text: productData['productionDate']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('แก้ไขข้อมูลสินค้า'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'ชื่อสินค้า'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'รายละเอียด'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'ประเภทสินค้า'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'จำนวน'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'ราคา'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: productionDateController,
                  decoration: InputDecoration(labelText: 'วันที่ผลิต'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                // อัปเดตข้อมูลใน Firebase
                await _productRef.child(productId).update({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'category': categoryController.text,
                  'quantity': int.parse(quantityController.text),
                  'price': double.parse(priceController.text),
                  'productionDate': productionDateController.text,
                });

                Navigator.pop(context);
                _fetchProducts(); // รีเฟรชข้อมูลหลังจากแก้ไข
              },
              child: Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'สินค้า (${widget.category})',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 189, 234, 255),
        elevation: 5,
        toolbarHeight: 70,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFAE3E3), // Light pink
              Color(0xFFEC9CA8), // Soft rose
              Color(0xFFF5D0D6), // Very light pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _filteredProducts.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        product['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: ${product['price']} THB'),
                          Text('Quantity: ${product['quantity']} ชิ้น'),
                          Text(
                              'Production Date: ${formatDate(product['productionDate'])}'),
                          if (product['description'] != null)
                            Text('Description: ${product['description']}'),
                        ],
                      ),
                      onTap: () {
                        // เปิดหน้าจอแก้ไขข้อมูลสินค้า
                        showEditDialog(product['id'], product);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
