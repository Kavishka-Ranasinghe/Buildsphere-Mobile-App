import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_room.dart';
import 'room_section.dart';
import 'c_item_shopping.dart';
import 'c_raw_supply_shopping.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userRole = userDoc['role'];
        });
      }
    }
  }

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
            title: const Text(
              'Room Section',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
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
            title: const Text(
              'Chat Rooms',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatRoomsScreen()),
              );
            },
          ),
          // Only show "Buy Items" and "Buy Raw Supplies" for Clients
          if (userRole == 'Client') ...[
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text(
                'Buy Items',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ItemShoppingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.construction),
              title: const Text(
                'Buy Raw Supplies',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RawSupplyScreen()),
                );
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text(
              'Close Menu',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
