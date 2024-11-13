import 'package:flutter/material.dart';
import 'profile.dart';
import 'app_drawer.dart';
import 'dashboard_item.dart';


class room_section extends StatelessWidget {
  const room_section({super.key});

  @override
  Widget build(BuildContext context) {
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
      drawer: const AppDrawer(), // Use the reusable AppDrawer
      body: Column(
        children: [
          Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room Section',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellowAccent,
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
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: const [
                DashboardItem(
                  icon: Icons.group_add,
                  label: 'Join Room',
                  color: Colors.blue,
                ),
                DashboardItem(
                  icon: Icons.add,
                  label: 'Create Room',
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
