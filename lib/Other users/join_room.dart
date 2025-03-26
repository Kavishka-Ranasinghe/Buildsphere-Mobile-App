import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

class JoinRoom extends StatefulWidget {
  const JoinRoom({super.key});

  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();

  Future<void> joinChatRoom() async {
    String guid = _roomIdController.text.trim();
    String roomName = _roomNameController.text.trim();

    if (guid.isEmpty || roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Room ID and Room Name")),
      );
      return;
    }

    await CometChat.joinGroup(
      guid,
      CometChatGroupType.password,
      password: roomName,
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
            // Room ID Field
            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(
                labelText: "Enter Room ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Room Name Field (used as password, but visible)
            TextField(
              controller: _roomNameController,
              decoration: const InputDecoration(
                labelText: "Enter Room Name",
                border: OutlineInputBorder(),
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
