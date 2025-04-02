import 'package:flutter/material.dart';
import 'hso_home.dart'; // Shop Owner Dashboard
import 'hso_add_product.dart'; // Add Product Page
import '../Other users/profile.dart'; // Profile Page
import '../about_page.dart'; // About Page

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _tapCount = 0; // Tap Counter

  void _incrementTapCount() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 3) {
        _tapCount = 0;
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.green,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _incrementTapCount,
                  child: const Text(
                    'BuildSphere',
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Main Menu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Dashboard (Shop Owner Page)
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.green),
            title: const Text(
              'Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HardwareShopOwnerPage()),
              );
            },
          ),

          // Add Product Section
          ListTile(
            leading: const Icon(Icons.add_box, color: Colors.green),
            title: const Text(
              'Add Product',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductPage()),
              );
            },
          ),

          const Divider(),

          // Close Menu
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text(
              'Close Menu',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the drawer
            },
          ),
        ],
      ),
    );
  }
}
