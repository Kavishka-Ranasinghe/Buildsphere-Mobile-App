import 'package:flutter/material.dart';
import 'hso_home.dart'; // Shop Owner Page
import 'hso_add_product.dart'; // Add Product Page
import '../Other users/profile.dart'; // Profile Page


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Home / Dashboard (Shop Owner Page)
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

          // Add Product Section (New Feature)
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
