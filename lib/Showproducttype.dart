import 'package:flutter/material.dart';
import 'showfiltertype.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 144, 209)),
        useMaterial3: true,
      ),
      home: ShowProductType(),
    );
  }
}

class ShowProductType extends StatefulWidget {
  @override
  State<ShowProductType> createState() => _ShowProductTypeState();
}

class _ShowProductTypeState extends State<ShowProductType> {
  final List<Map<String, dynamic>> items1 = [
    {
      'name': 'Electronics',
      'icon': Icons.devices,
    },
    {
      'name': 'Clothing',
      'icon': Icons.checkroom,
    },
    {
      'name': 'Food',
      'icon': Icons.fastfood,
    },
    {
      'name': 'Books',
      'icon': Icons.book,
    },
  ];

  // List of colors for each item
  final List<Color> colors = [
    Color.fromARGB(255, 236, 156, 168),
    Color.fromARGB(255, 255, 204, 128),
    Color.fromARGB(255, 159, 201, 243),
    Color.fromARGB(255, 173, 223, 173),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ประเภทของสินค้า',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Color.fromARGB(255, 200, 180, 255),
        centerTitle: true,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: items1.length,
                itemBuilder: (context, index) {
                  final item = items1[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowFilterType(
                            category: item['name'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors[index % colors.length], // Assign color
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Icon(
                              item['icon'],
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            item['name'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
