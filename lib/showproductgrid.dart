import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Method หลักที่ Run
void main() {
  runApp(MyApp());
}

// Class stateless สั่งแสดงผลหน้าจอ
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: showproductgrid(),
    );
  }
}

// Class stateful เรียกใช้การทำงานแบบโต้ตอบ
class showproductgrid extends StatefulWidget {
  @override
  State<showproductgrid> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<showproductgrid> {
  // ส่วนเขียน Code ภาษา Dart เพื่อรับค่าจากหน้าจอมาคำนวณหรือมาทำบางอย่างและส่งค่ากลับไป

  DatabaseReference dbRef = FirebaseDatabase.instance.ref('products');
  List<Map<String, dynamic>> products = [];

  ///////////////////////////////////////////////////////////////////////////
  Future<void> fetchProducts() async {
    try {
      // ดึงข้อมูลทั้งหมดจาก Realtime Database
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        List<Map<String, dynamic>> loadedProducts = [];
        snapshot.children.forEach((child) {
          Map<String, dynamic> product =
              Map<String, dynamic>.from(child.value as Map);
          product['key'] = child.key; // เก็บ key สำหรับการอ้างอิง
          loadedProducts.add(product);
        });

        // เรียงข้อมูลตามราคาจากมากไปน้อย
        loadedProducts.sort((b, a) => b['price'].compareTo(a['price']));

        // อัปเดต state เพื่อแสดงข้อมูล
        setState(() {
          products = loadedProducts;
        });
        print("จำนวนรายการสินค้าทั้งหมด: ${products.length} รายการ");
      } else {
        print("ไม่พบรายการสินค้าในฐานข้อมูล");
      }
    } catch (e) {
      print("Error loading products: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts(); // เรียกใช้เมื่อ Widget ถูกสร้าง
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd-MMMM-yyyy').format(parsedDate);
  }

  // ฟังก์ชันที่ใช้ลบ
  void deleteProduct(String key, BuildContext context) {
    dbRef.child(key).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบสินค้าเรียบร้อย')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  // ฟังก์ชันถามยืนยันก่อนลบ
  void showDeleteConfirmationDialog(String key, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด Dialog โดยการแตะนอกพื้นที่
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('ยืนยันการลบ'),
          content: Text('คุณแน่ใจว่าต้องการลบสินค้านี้ใช่หรือไม่?'),
          actions: [
            // ปุ่มยกเลิก
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิด Dialog
              },
              child: Text('ไม่ลบ'),
            ),
            // ปุ่มยืนยันการลบ
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิด Dialog
                deleteProduct(key, context); // เรียกฟังก์ชันลบข้อมูล
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ลบข้อมูลเรียบร้อยแล้ว'),
                    backgroundColor: Colors.green,
                  ),
                );
                fetchProducts();
              },
              child: Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันแสดง AlertDialog หน้าจอเพื่อแก้ไขข้อมูล
  void showEditProductDialog(Map<String, dynamic> product) {
    TextEditingController nameController =
        TextEditingController(text: product['name']);
    TextEditingController descriptionController =
        TextEditingController(text: product['description']);
    TextEditingController priceController =
        TextEditingController(text: product['price'].toString());
    TextEditingController categoryController =
        TextEditingController(text: product['category'].toString());
    TextEditingController quantityController =
        TextEditingController(text: product['quantity'].toString());

    DateTime productionDate = DateTime.parse(product['productionDate']);
    TextEditingController productionDateController = TextEditingController(
        text: DateFormat('dd-MMMM-yyyy').format(productionDate));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('แก้ไขข้อมูลสินค้า'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'ราคา'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'ประเภทสินค้า'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'จำนวน'),
                ),
                TextField(
                  controller: productionDateController,
                  decoration: InputDecoration(labelText: 'วันที่ผลิต'),
                  readOnly: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิด Dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Map<String, dynamic> updatedData = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': int.parse(priceController.text),
                  'category': categoryController.text,
                  'quantity': int.parse(quantityController.text),
                  'productionDate':
                      DateFormat('yyyy-MM-dd').format(productionDate),
                };
                dbRef.child(product['key']).update(updatedData).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('แก้ไขข้อมูลเรียบร้อย')),
                  );
                  fetchProducts();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $error')),
                  );
                });

                Navigator.of(dialogContext).pop(); // ปิด Dialog
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Text(
              'แสดงข้อมูลสินค้า',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 184, 222, 255),
        elevation: 5,
        toolbarHeight: 70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 250, 155, 188), // ชมพูสด
              Color.fromARGB(255, 149, 209, 231), // ฟ้าสด
            ],
            stops: [0.0, 1.0], // กำหนดจุดเริ่มต้นและจุดสิ้นสุดของการไล่สี
          ),
        ),
        child: products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: products.length,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      print("Selected product: ${product['name']}");
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white,
                      shadowColor: Colors.grey.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                product['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'รายละเอียดสินค้า: ${product['description']}',
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'ราคา: ${product['price']} บาท',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showEditProductDialog(product);
                                  },
                                  icon: Icon(Icons.edit),
                                  color: Color.fromARGB(255, 230, 112, 210),
                                  iconSize: 28,
                                  tooltip: 'แก้ไขสินค้า',
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDeleteConfirmationDialog(
                                        product['key'], context);
                                  },
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  iconSize: 28,
                                  tooltip: 'ลบสินค้า',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
