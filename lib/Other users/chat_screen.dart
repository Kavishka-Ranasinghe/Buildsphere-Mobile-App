import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// ✅ FIX: Implementing MessageListener as a mixin
class _ChatScreenState extends State<ChatScreen> with MessageListener {
  final TextEditingController _messageController = TextEditingController();
  List<BaseMessage> messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
    CometChat.addMessageListener("chat_listener", this); // ✅ Register listener
  }

  // ✅ FIX: Properly fetching chat messages
  Future<void> fetchMessages() async {
    int limit = 30;
    String guid = widget.roomId;

    // ✅ FIX: Proper usage of MessagesRequestBuilder
    MessagesRequest messagesRequest = MessagesRequestBuilder()
        .set(guid: guid) // ✅ Correct method usage
        .set(limit: limit)
        .build();

    messagesRequest.fetchPrevious(
      onSuccess: (List<BaseMessage> fetchedMessages) {
        setState(() {
          messages = fetchedMessages.reversed.toList();
        });
      },
      onError: (CometChatException e) {
        debugPrint("❌ Failed to Fetch Messages: ${e.message}");
      },
    );
  }

  // ✅ FIX: Implement `onTextMessageReceived` in mixin
  @override
  void onTextMessageReceived(TextMessage textMessage) {
    if (textMessage.receiverUid == widget.roomId) {
      setState(() {
        messages.add(textMessage);
      });
    }
  }

  // ✅ FIX: Properly sending messages with correct type
  Future<void> sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    TextMessage message = TextMessage(
      receiverUid: widget.roomId,
      receiverType: CometChatReceiverType.group,
      text: messageText,
      type: CometChatMessageType.text, // ✅ Correct `type` parameter
    );

    await CometChat.sendMessage(
      message,
      onSuccess: (BaseMessage sentMessage) {
        setState(() {
          messages.add(sentMessage);
          _messageController.clear();
        });
      },
      onError: (CometChatException e) {
        debugPrint("❌ Message Sending Failed: ${e.message}");
      },
    );
  }

  @override
  void dispose() {
    CometChat.removeMessageListener("chat_listener"); // ✅ Remove listener when screen is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName)),
      body: Column(
        children: [
          // ✅ Messages List
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                BaseMessage message = messages[index];

                return FutureBuilder<User?>(
                  future: CometChat.getLoggedInUser(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    bool isSentByMe = message.sender?.uid == snapshot.data?.uid;

                    return Align(
                      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          (message as TextMessage).text,
                          style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // ✅ Message Input Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Type a message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on MessagesRequestBuilder {
  set({required String guid}) {}
}
