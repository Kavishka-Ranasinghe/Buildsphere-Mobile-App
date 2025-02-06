import 'package:flutter/material.dart';
import 'hso_profile_edit.dart';
import 'hso_app_drawer.dart';
import 'edit_product_page.dart';

class HardwareShopOwnerPage extends StatefulWidget {
  const HardwareShopOwnerPage({super.key});

  @override
  _HardwareShopOwnerPageState createState() => _HardwareShopOwnerPageState();
}

class _HardwareShopOwnerPageState extends State<HardwareShopOwnerPage> {
  String selectedCategory = 'All';

  // Hardcoded shop name for now (can be dynamically loaded later)
  final String shopName = "Prime_Hardware";

  final List<String> categories = ['All', 'Cement', 'Soil', 'Brick', 'Pebbles'];

  @override
  Widget build(BuildContext context) {
    // Ensure each product has a category before filtering
    List<Map<String, dynamic>> filteredMaterials = rawMaterials.where((material) {
      if (selectedCategory == 'All') return true;
      return material['category']?.toString().toLowerCase() == selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buildup Ceylon',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopName,  // Shop Name on the first line
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellowAccent,
                        ),
                      ),
                      Text(
                        'Products',  // "Products" on the second line
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/profile.gif'),
                    radius: 24,
                  ),
                ),
              ],
            ),
          ),

          // Category Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: selectedCategory == category ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedCategory == category ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Products List
          Expanded(
            child: filteredMaterials.isEmpty
                ? const Center(
              child: Text(
                'No products available in this category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredMaterials.length,
              itemBuilder: (context, index) {
                final material = filteredMaterials[index];

                return GestureDetector(
                  onTap: () async {
                    final updatedMaterial = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductPage(material: material),
                      ),
                    );
                    if (updatedMaterial != null) {
                      setState(() {
                        material['name'] = updatedMaterial['name'] ?? 'Unknown Product';
                        material['price'] = updatedMaterial['price'] ?? '0';
                        material['category'] = updatedMaterial['category'] ?? 'Uncategorized';
                      });
                    }
                  },
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(
                        material['name'] ?? 'Unknown Product',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Price: ${material['price'] ?? '0'} LKR'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Sample data for raw building materials
List<Map<String, dynamic>> rawMaterials = [
  {'name': 'Lanwa Cement', 'price': '1000', 'category': 'Cement'},
  {'name': 'Tokyo Cement', 'price': '1250', 'category': 'Cement'},
  {'name': 'River Sand', 'price': '500', 'category': 'Soil'},
  {'name': 'Pebbles', 'price': '5000', 'category': 'Pebbles'},
  {'name': 'Bricks', 'price': '50', 'category': 'Brick'},
];
