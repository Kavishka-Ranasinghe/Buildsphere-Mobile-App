import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

class JoinRoom extends StatefulWidget {
  const JoinRoom({super.key});

  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final TextEditingController _roomIdController = TextEditingController();

  Future<void> joinChatRoom() async {
    String guid = _roomIdController.text.trim();
    if (guid.isEmpty) return;

    await CometChat.joinGroup(
      guid,
      CometChatGroupType.public,
      onSuccess: (Group joinedGroup) {
        print("✅ Joined Chat Room: ${joinedGroup.guid}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Joined Room '${joinedGroup.name}' Successfully joined!")),
        );
        Navigator.pop(context); // Return to the previous screen after joining room
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
