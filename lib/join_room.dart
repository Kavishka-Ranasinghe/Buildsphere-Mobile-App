import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'Other users/dashboard_item.dart';
import 'chat_room.dart';

class JoinRoom extends StatelessWidget {
  const JoinRoom({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController roomIdController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Join Room',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
          ),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellowAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const AppDrawer(), // Use the reusable AppDrawer
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: roomIdController,
              decoration: const InputDecoration(
                labelText: 'Room ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatRoomsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text(
                'Enter Room',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
