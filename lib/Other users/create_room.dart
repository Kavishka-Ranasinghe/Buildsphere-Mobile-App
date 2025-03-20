import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final TextEditingController _roomNameController = TextEditingController();

  Future<void> createChatRoom() async {
    String groupName = _roomNameController.text.trim();
    if (groupName.isEmpty) return;

    String guid = groupName.toLowerCase().replaceAll(" ", "_");

    // ✅ Properly await the logged-in user
    User? loggedInUser = await CometChat.getLoggedInUser();
    String ownerUid = loggedInUser?.uid ?? ""; // Assign UID if user is logged in

    // ✅ Corrected Group Constructor
    Group group = Group(
      guid: guid, // Unique Group ID
      name: groupName, // Group Name
      type: CometChatGroupType.public, // Group Type (public/private/password)
      owner: ownerUid, // Owner (Current User ID)
    );

    await CometChat.createGroup(
      group: group, // ✅ Pass group as a named parameter
      onSuccess: (Group createdGroup) {
        print("✅ Chat Room Created: ${createdGroup.guid}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Chat Room '${createdGroup.name}' Created Successfully!")),
        );
        Navigator.pop(context); // Return to previous page after creating room
      },
      onError: (CometChatException e) {
        print("❌ Chat Room Creation Failed: ${e.message}");
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
            TextField(
              controller: _roomNameController,
              decoration: const InputDecoration(
                labelText: "Enter Room Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
