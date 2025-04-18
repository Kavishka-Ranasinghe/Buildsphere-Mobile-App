import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../no_internet_screen.dart';
import 'app_drawer.dart';
import 'chat_screen.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  _ChatRoomsScreenState createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> with MessageListener {
  List<Conversation> groupConversations = [];
  bool isLoading = true;
  bool _isConnected = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _checkInternet();
    fetchUserChatRooms();
    CometChat.addMessageListener("room_listener", this);

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchUserChatRooms(forceUpdate: true);
    });
  }

  Future<void> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    CometChat.removeMessageListener("room_listener");
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void onTextMessageReceived(TextMessage message) async {
    await fetchUserChatRooms(forceUpdate: true);
  }

  Future<void> fetchUserChatRooms({bool forceUpdate = false}) async {
    try {
      ConversationsRequest request = (ConversationsRequestBuilder()
        ..limit = 50).build();

      await request.fetchNext(
        onSuccess: (List<Conversation> conversations) {
          final filtered = conversations
              .where((c) => c.conversationType == "group")
              .toList();

          filtered.sort((a, b) {
            final aSent = a.lastMessage?.sentAt is int ? a.lastMessage?.sentAt as int : 0;
            final bSent = b.lastMessage?.sentAt is int ? b.lastMessage?.sentAt as int : 0;
            return bSent.compareTo(aSent);
          });

          if (forceUpdate || filtered.length != groupConversations.length) {
            setState(() {
              groupConversations = List.from(filtered);
              isLoading = false;
            });
          }
        },
        onError: (CometChatException e) {
          print("❌ Failed to fetch conversations: ${e.message}");
          setState(() => isLoading = false);
        },
      );
    } catch (e) {
      print("❌ Exception while fetching conversations: $e");
      setState(() => isLoading = false);
    }
  }

  String formatTime(int? timestamp) {
    if (timestamp == null) return "";
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return const NoInternetScreen(); // ✅ Show offline UI
    }

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
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : groupConversations.isEmpty
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
              itemCount: groupConversations.length,
              itemBuilder: (context, index) {
                final convo = groupConversations[index];
                final group = convo.conversationWith as Group;
                final lastMsg = convo.lastMessage;
                final time = lastMsg?.sentAt is int
                    ? formatTime(lastMsg?.sentAt as int)
                    : "";
                final preview = (lastMsg is TextMessage)
                    ? lastMsg.text
                    : "Media/Action";

                return Card(
                  color: Colors.white.withOpacity(0.9),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(
                      group.type == CometChatGroupType.password
                          ? Icons.lock
                          : Icons.lock_open,
                      color: Colors.green,
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lastMsg != null
                          ? "$preview  •  $time"
                          : "No messages yet",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
