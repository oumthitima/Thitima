import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'addproduct.dart';
import 'ShowProduct.dart';
import 'Showproducttype.dart';
import 'showproductgrid.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDN_VPuznZKSjx5zYrwvEUfsLQDAnxCFKw",
        authDomain: "onlinefirebase-c0650.firebaseapp.com",
        databaseURL: "https://onlinefirebase-c0650-default-rtdb.firebaseio.com",
        projectId: "onlinefirebase-c0650",
        storageBucket: "onlinefirebase-c0650.firebasestorage.app",
        messagingSenderId: "1098758877810",
        appId: "1:1098758877810:web:32495bafca40a2bb5848eb",
        measurementId: "G-E2W15YQC29",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late DatabaseReference _productRef;

  @override
  void initState() {
    super.initState();
    _productRef = FirebaseDatabase.instance.ref('products');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ระบบจัดการข้อมูล',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Color.fromARGB(255, 190, 208, 240),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg1.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // เพิ่มโลโก้ตรงกลางเป็นวงกลม
                  CircleAvatar(
                    radius: 100, // ขนาดของวงกลม
                    backgroundImage: AssetImage('assets/logo.png'), // โลโก้
                    backgroundColor: Colors.transparent, // ทำให้พื้นหลังโปร่งใส
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProduct(),
                        ),
                      );
                    },
                    icon: Icon(Icons.inventory_2, color: Colors.white),
                    label: Text(
                      'จัดการข้อมูลสินค้า',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 165, 233, 246),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => showproductgrid()),
                      );
                    },
                    icon: Icon(Icons.store_mall_directory, color: Colors.white),
                    label: Text(
                      'จัดการแสดงข้อมูลสินค้า',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 245, 172, 183),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowProductType()),
                      );
                    },
                    icon: Icon(Icons.category, color: Colors.white),
                    label: Text(
                      'จัดการข้อมูลประเภทสินค้า',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 200, 180, 255),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
