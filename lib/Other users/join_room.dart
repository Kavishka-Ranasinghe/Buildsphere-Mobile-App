import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

class JoinRoom extends StatefulWidget {
  const JoinRoom({super.key});

  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> joinChatRoom() async {
    String guid = _roomIdController.text.trim();
    String password = _passwordController.text.trim();

    if (guid.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Room ID and Password")),
      );
      return;
    }

    await CometChat.joinGroup(
      guid,
      CometChatGroupType.password,
      password: password,
      onSuccess: (Group joinedGroup) {
        print("✅ Joined Chat Room: ${joinedGroup.guid}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Joined Room '${joinedGroup.name}' successfully!")),
        );
        Navigator.pop(context);
      },
      onError: (CometChatException e) {
        print("❌ Failed to Join Chat Room: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to join room: ${e.message}")),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Chat Room")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(
                labelText: "Enter Room ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🔐 Password Field with toggle
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Enter Room Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: joinChatRoom,
              child: const Text("Join Room"),
            ),
          ],
        ),
      ),
    );
  }
}
