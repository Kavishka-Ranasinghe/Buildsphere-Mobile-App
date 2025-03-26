import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
// ✅ Rename CometChat's Action model to avoid conflict
import 'package:cometchat_sdk/models/action.dart' as cometchat;

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with MessageListener {
  final TextEditingController _messageController = TextEditingController();
  List<BaseMessage> messages = [];
  MessagesRequest? _messagesRequest;

  @override
  void initState() {
    super.initState();

    _messagesRequest = (MessagesRequestBuilder()
      ..guid = widget.roomId
      ..limit = 30
    ).build();

    fetchMessages();
    CometChat.addMessageListener("chat_listener", this);
  }

  Future<void> fetchMessages() async {
    if (_messagesRequest == null) return;

    _messagesRequest!.fetchPrevious(
      onSuccess: (List<BaseMessage> fetchedMessages) {
        debugPrint("✅ Retrieved ${fetchedMessages.length} messages");
        setState(() {
          messages = fetchedMessages.reversed.toList();
        });
      },
      onError: (CometChatException e) {
        debugPrint("❌ Failed to fetch messages: ${e.message}");
      },
    );
  }

  @override
  void onTextMessageReceived(TextMessage textMessage) {
    if (textMessage.receiverUid == widget.roomId) {
      setState(() {
        messages.add(textMessage);
      });
    }
  }

  Future<void> sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    TextMessage message = TextMessage(
      receiverUid: widget.roomId,
      receiverType: CometChatReceiverType.group,
      text: messageText,
      type: CometChatMessageType.text,
    );

    await CometChat.sendMessage(
      message,
      onSuccess: (BaseMessage sentMessage) {
        debugPrint("✅ Message sent: ${sentMessage.id}");
        setState(() {
          messages.add(sentMessage);
          _messageController.clear();
        });
      },
      onError: (CometChatException e) {
        debugPrint("❌ Message sending failed: ${e.message}");
      },
    );
  }

  @override
  void dispose() {
    CometChat.removeMessageListener("chat_listener");
    _messagesRequest = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                BaseMessage message = messages[index];

                return FutureBuilder<User?>(
                  future: CometChat.getLoggedInUser(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    bool isSentByMe = message.sender?.uid == snapshot.data?.uid;

                    // ✅ Text Message
                    if (message is TextMessage) {
                      return Align(
                        alignment: isSentByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: isSentByMe
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: isSentByMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }

                    // ✅ Group Action Message (joined, left, etc.)
                    else if (message is cometchat.Action) {
                      final actionType = message.action?.toLowerCase();

                      // Show only important actions like leave, kick, ban
                      if (actionType == "leave" || actionType == "kick" || actionType == "ban") {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              "⚠️ ${message.message}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox(); // hide join, add, etc.
                      }
                    }


                    // ❌ Unsupported messages
                    else {
                      return const SizedBox();
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                        hintText: "Type a message..."),
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
