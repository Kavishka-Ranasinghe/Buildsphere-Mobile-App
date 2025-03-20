import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
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
      // ✅ Ensure proper instantiation of GroupsRequest
      GroupsRequest groupsRequest = (GroupsRequestBuilder()..limit = 50).build();

      // ✅ Properly call fetchNext()
      await groupsRequest.fetchNext(
        onSuccess: (List<Group> groups) {
          setState(() {
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
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/modern.png', // Ensure this image is in your assets folder
              fit: BoxFit.cover,
            ),
          ),
          // Chat Room List
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading spinner
              : userGroups.isEmpty
              ? Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'No chat rooms found. Join or create a room!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          )
              : ListView.builder(
            itemCount: userGroups.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(userGroups[index].name),
                  subtitle: Text("Room ID: ${userGroups[index].guid}"),
                  leading: const Icon(Icons.chat, color: Colors.green),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          roomId: userGroups[index].guid, // ✅ Pass Room ID
                          roomName: userGroups[index].name, // ✅ Pass Room Name
                        ),
                      ),
                    );
                  },
                ),

              );
            },
          ),
        ],
      ),
    );
  }
}
