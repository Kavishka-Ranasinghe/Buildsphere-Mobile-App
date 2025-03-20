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
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/modern.png', // Ensure this image is in your assets folder
              fit: BoxFit.cover,
            ),
          ),
          // Centered Welcome Text
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), // Semi-transparent background for readability
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Welcome to Chat Room \n'
                'Still under construction',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
