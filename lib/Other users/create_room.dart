import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:flutter/services.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _confirmNameController = TextEditingController();
  late String _generatedRoomId;

  @override
  void initState() {
    super.initState();
    _generatedRoomId = "room_${generateRandomID(10)}";
  }

  String generateRandomID(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  Future<void> createChatRoom() async {
    String groupName = _roomNameController.text.trim();
    String confirmName = _confirmNameController.text.trim();

    if (groupName.isEmpty || confirmName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    if (groupName != confirmName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group names do not match")),
      );
      return;
    }

    User? loggedInUser = await CometChat.getLoggedInUser();
    String ownerUid = loggedInUser?.uid ?? "";

    Group group = Group(
      guid: _generatedRoomId,
      name: groupName,
      type: CometChatGroupType.password,
      password: groupName, // ✅ group name is used as password
      owner: ownerUid,
    );

    await CometChat.createGroup(
      group: group,
      onSuccess: (Group createdGroup) {
        print("✅ Chat Room Created: ${createdGroup.guid}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Room '${createdGroup.name}' Created!\nRoom ID: ${createdGroup.guid}")),
        );
        Navigator.pop(context);
      },
      onError: (CometChatException e) {
        print("❌ Room Creation Failed: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create room: ${e.message}")),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Chat Room")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔐 Room ID
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: _generatedRoomId),
                    decoration: const InputDecoration(
                      labelText: "Room ID (share this)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generatedRoomId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Room ID copied!")),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📝 Group Name
            TextField(
              controller: _roomNameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Confirm Group Name
            TextField(
              controller: _confirmNameController,
              decoration: const InputDecoration(
                labelText: "Confirm Group Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: createChatRoom,
              child: const Text("Create Room"),
            ),
          ],
        ),
      ),
    );
  }
}
