import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Other users/profile.dart';
import 'app_drawer.dart';

class ItemShoppingScreen extends StatelessWidget {
  const ItemShoppingScreen({super.key});

  // Function to search for an item
  void _searchItem(String query, BuildContext context) async {
    if (query.isEmpty) {
      // Show error if search field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an item to search."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final darazAppUrl = 'daraz://search?q=${Uri.encodeComponent(query)}'; // Daraz app deep link
    final darazWebUrl =
        'https://www.daraz.lk/catalog/?spm=a2a0e.tm80335410.search.d_go&q=${Uri.encodeComponent(query)}';

    if (await canLaunchUrl(Uri.parse(darazAppUrl))) {
      // If the Daraz app is installed, open the app
      await launchUrl(Uri.parse(darazAppUrl));
    } else {
      // If the Daraz app is not installed, open in a web browser
      await launchUrl(
        Uri.parse(darazWebUrl),
        mode: LaunchMode.externalApplication, // Ensures opening in a web browser
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buildsphere',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Background Image with Blur Effect
          Positioned.fill(
            child: Image.asset(
              'assets/images/modern.png', // Ensure this image is in your assets folder
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Adds blur effect
              child: Container(
                color: Colors.black.withOpacity(0.2), // Slight dark overlay
              ),
            ),
          ),
          Column(
            children: [
              // Header with Profile Icon
              Container(
                color: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Item Shopping',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellowAccent,
                        ),
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
              // Centering the Search and Buttons
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, // Solid White Background
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green, width: 5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                labelText: 'Search for an item',
                                prefixIcon: Icon(Icons.search, color: Colors.black54),
                                border: InputBorder.none, // Remove default border
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              style: const TextStyle(color: Colors.black),
                              onSubmitted: (query) => _searchItem(query, context),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Buttons with Filled White Background
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFilledButton(
                                icon: Icons.search,
                                label: "Search",
                                onPressed: () {
                                  _searchItem(searchController.text, context);
                                },
                              ),
                              const SizedBox(width: 20),
                              _buildFilledButton(
                                icon: Icons.camera_alt,
                                label: "Scan Item",
                                onPressed: () {
                                  // Placeholder for Google Vision API functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Opening camera to scan item...")),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilledButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black, // Button background color
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton.icon(
          icon: Icon(icon, color: Colors.black),
          label: Text(label, style: const TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // White background for button
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 2,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
