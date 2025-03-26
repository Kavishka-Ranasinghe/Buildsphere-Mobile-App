import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:flutter/services.dart';
import 'app_drawer.dart';
import 'chat_screen.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  _ChatRoomsScreenState createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  List<Group> userGroups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserChatRooms();
  }

  // ✅ Fetch Chat Rooms from CometChat
  Future<void> fetchUserChatRooms() async {
    try {
      GroupsRequest groupsRequest = (GroupsRequestBuilder()
        ..limit = 50
        ..joinedOnly = true
      ).build();


      await groupsRequest.fetchNext(
        onSuccess: (List<Group> groups) {
          setState(() {
            userGroups.clear();
            userGroups = groups;
            isLoading = false;
          });
        },
        onError: (CometChatException e) {
          print("❌ Failed to Fetch Chat Rooms: ${e.message}");
          setState(() {
            isLoading = false;
          });
        },
      );
    } catch (e) {
      print("❌ Exception while fetching chat rooms: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
          Positioned.fill(
            child: Image.asset(
              'assets/images/modern.png',
              fit: BoxFit.cover,
            ),
          ),

          isLoading
              ? const Center(child: CircularProgressIndicator())
              : userGroups.isEmpty
              ? Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No chat rooms found.\nJoin or create a room!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: fetchUserChatRooms,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          )
              : RefreshIndicator(
            onRefresh: fetchUserChatRooms,
            child: ListView.builder(
              itemCount: userGroups.length,
              itemBuilder: (context, index) {
                final group = userGroups[index];
                final joinedDate = group.joinedAt;


                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(
                      group.type == CometChatGroupType.password
                          ? Icons.lock
                          : Icons.lock_open,
                      color: Colors.green,
                    ),
                    title: Text(group.name),
                    subtitle: Text(
                      "Room ID: ${group.guid}\n"
                          "Members: ${group.membersCount ?? 'N/A'}\n"
                          "${joinedDate != null ? "Joined: ${joinedDate.toLocal().toString().split('.')[0]}" : ""}",
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            roomId: group.guid,
                            roomName: group.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
