import 'package:flutter/material.dart';
import 'chat_room.dart';
import 'room_section.dart';
import 'c_item_shopping.dart'; // Import ItemShoppingScreen

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
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Room Section', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const room_section()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat Rooms', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatRoomsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Buy Items', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ItemShoppingScreen()), // Navigate to ItemShoppingScreen
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.construction),
            title: const Text('Buy Raw Supplies', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            onTap: () {
              Navigator.pop(context);
              // Add navigation code for Buy Raw Supplies
            },
          ),
          Divider(), // Optional divider to separate the Cancel button
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Close Menu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            onTap: () {
              Navigator.pop(context); // Closes the drawer
            },
          ),
        ],
      ),
    );
  }
}
