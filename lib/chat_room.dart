import 'package:flutter/material.dart';
import 'profile.dart';
import 'app_drawer.dart';

class ChatRoomsScreen extends StatelessWidget {
  const ChatRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define groupChats inside the build method
    final List<String> groupChats = [
      'Family Group',
      'Friends Group',
      'Work Group',
      'Project Team',
    ];

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
      drawer: const AppDrawer(), // Use the reusable AppDrawer here
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
                        'Chat Room',
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
            child: ListView.builder(
              itemCount: groupChats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      groupChats[index][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(groupChats[index]),
                  subtitle: const Text('Last message here...'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Opening ${groupChats[index]}")),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
