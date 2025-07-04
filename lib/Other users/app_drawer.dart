import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_rooms.dart';
import 'room_section.dart';
import 'Customer/c_item_shopping.dart';
import 'Customer/c_raw_supply_shopping.dart';
import '../about_page.dart';
import 'profile.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? userRole;
  String? userName;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userRole = userDoc['role'];
          userName = userDoc['name'];
        });
      }
    }
  }

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
                const SizedBox(height: 10),
                const Text(
                  'Main Menu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                if (userName != null && userRole != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Name: $userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Role: $userRole',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],


              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'My Profile',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
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
