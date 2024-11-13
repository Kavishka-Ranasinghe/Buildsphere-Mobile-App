import 'package:flutter/material.dart';
import 'app_drawer.dart';

class ChatRoomsScreen extends StatelessWidget {
  const ChatRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms'),
        backgroundColor: Colors.green,
      ),
      drawer: const AppDrawer(), // Add the AppDrawer here
      body: Center(
        child: const Text(
          'Welcome to the Chat Room!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
