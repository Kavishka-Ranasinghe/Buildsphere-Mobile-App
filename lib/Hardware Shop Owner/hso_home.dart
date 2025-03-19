import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final List<String> categories = ['All', 'Cement', 'Soil', 'Brick', 'Pebbles'];

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buildsphere',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/modern.png', // Add this image to assets
              fit: BoxFit.cover,
            ),
          ),
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          Column(
            children: [
              // Fetch and Display Shop Name Dynamically
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String shopName = "Loading...";

                  if (snapshot.hasData && snapshot.data?.exists == true) {
                    shopName = snapshot.data?['shopName'] ?? "Unknown Shop";
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shopName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellowAccent,
                                ),
                              ),
                              const Text(
                                'Products',
                                style: TextStyle(
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
                  );
                },
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
                            boxShadow: [
                              if (selectedCategory == category)
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                            ],
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rawMaterials.length,
                  itemBuilder: (context, index) {
                    final material = rawMaterials[index];

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/item_placeholder.png'),
                          radius: 25,
                        ),
                        title: Text(
                          material['name'] ?? 'Unknown Product',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Price: ${material['price'] ?? '0'} LKR',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProductPage(material: {},),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Sample data for raw building materials.
List<Map<String, dynamic>> rawMaterials = [
  {'name': 'Lanwa Cement', 'price': '1000', 'category': 'Cement'},
  {'name': 'Tokyo Cement', 'price': '1250', 'category': 'Cement'},
  {'name': 'River Sand', 'price': '500', 'category': 'Soil'},
  {'name': 'Pebbles', 'price': '5000', 'category': 'Pebbles'},
  {'name': 'Bricks', 'price': '50', 'category': 'Brick'},
];
