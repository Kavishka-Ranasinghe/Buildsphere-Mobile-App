import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'hso_profile.dart';
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .where('ownerId', isEqualTo: currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filteredProducts = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (selectedCategory == 'All') return true;
                      return data['category'] == selectedCategory;
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No products found for this category.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index].data() as Map<String, dynamic>;

                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[300],
                              child: ClipOval(
                                child: Image.network(
                                  product['imageUrl'],
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                ),
                              ),
                            ),

                            title: Text(
                              product['name'] ?? 'Unnamed Product',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Price: ${product['price']} LKR',
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProductPage(material: product),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )

            ],
          ),
        ],
      ),
    );
  }
}

