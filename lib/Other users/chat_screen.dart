import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:cometchat_sdk/models/action.dart' as cometchat;
import 'package:intl/intl.dart';
import 'group_info_page.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with MessageListener {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<BaseMessage> messages = [];
  MessagesRequest? _messagesRequest;
  bool _showScrollDownButton = false;
  bool _isLoadingOldMessages = false;

  @override
  void initState() {
    super.initState();

    _messagesRequest = (MessagesRequestBuilder()
      ..guid = widget.roomId
      ..limit = 30)
        .build();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      // 👇 Load older messages if user scrolls to top
      if (_scrollController.offset <= 100 && !_isLoadingOldMessages) {
        loadOlderMessages();
      }

      const threshold = 300.0;
      if (_scrollController.offset <
          _scrollController.position.maxScrollExtent - threshold) {
        if (!_showScrollDownButton) {
          setState(() {
            _showScrollDownButton = true;
          });
        }
      } else {
        if (_showScrollDownButton) {
          setState(() {
            _showScrollDownButton = false;
          });
        }
      }
    });

    fetchMessages();
    CometChat.addMessageListener("chat_listener", this);
  }

  Future<void> fetchMessages() async {
    if (_messagesRequest == null) return;

    _messagesRequest!.fetchPrevious(
      onSuccess: (List<BaseMessage> fetchedMessages) {
        setState(() {
          messages = fetchedMessages.reversed.toList();
        });
        _scrollToBottom();
      },
      onError: (CometChatException e) {
        debugPrint("❌ Failed to fetch messages: ${e.message}");
      },
    );
  }

  Future<void> loadOlderMessages() async {
    if (_messagesRequest == null || _isLoadingOldMessages) return;
    _isLoadingOldMessages = true;

    _messagesRequest!.fetchPrevious(
      onSuccess: (List<BaseMessage> olderMessages) {
        if (olderMessages.isNotEmpty) {
          setState(() {
            messages.insertAll(0, olderMessages.reversed.toList());
          });
        }
        _isLoadingOldMessages = false;
      },
      onError: (CometChatException e) {
        debugPrint("⚠️ Error fetching older messages: ${e.message}");
        _isLoadingOldMessages = false;
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scrollController.hasClients) {
          final bottomOffset = _scrollController.position.maxScrollExtent + 100;

          _scrollController.animateTo(
            bottomOffset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }


  @override
  void onTextMessageReceived(TextMessage textMessage) {
    if (textMessage.receiverUid == widget.roomId) {
      final isNearBottom = _scrollController.hasClients &&
          _scrollController.offset >=
              _scrollController.position.maxScrollExtent - 400;

      setState(() {
        messages.add(textMessage);
      });

      if (isNearBottom) {
        _scrollToBottom();
      }
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
        setState(() {
          messages.add(sentMessage);
          _messageController.clear();
        });
        _scrollToBottom();
      },
      onError: (CometChatException e) {
        debugPrint("❌ Message sending failed: ${e.message}");
      },
    );
  }

  String formatTimeOnly(DateTime? timestamp) {
    if (timestamp == null) return "";
    return DateFormat('h:mm a').format(timestamp.toLocal());
  }

  @override
  void dispose() {
    CometChat.removeMessageListener("chat_listener");
    _messagesRequest = null;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupInfoPage(groupId: widget.roomId),
              ),
            );
          },
          child: Text(widget.roomName),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60), // avoids overlap
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      BaseMessage message = messages[index];

                      return FutureBuilder<User?>(
                        future: CometChat.getLoggedInUser(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();

                          bool isSentByMe =
                              message.sender?.uid == snapshot.data?.uid;

                          if (message is TextMessage) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Row(
                                mainAxisAlignment: isSentByMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: isSentByMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        if (!isSentByMe)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Text(
                                              message.sender?.name ?? "Unknown",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isSentByMe
                                                ? Colors.blueAccent
                                                : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message.text,
                                                style: TextStyle(
                                                  color: isSentByMe
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                formatTimeOnly(message.sentAt),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isSentByMe
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (message is cometchat.Action) {
                            final actionType = message.action?.toLowerCase();
                            if (actionType == "leave" ||
                                actionType == "kick" ||
                                actionType == "ban") {
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
                              return const SizedBox();
                            }
                          }

                          return const SizedBox();
                        },
                      );
                    },
                  ),
                ),
              ),
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

          // 🔽 Scroll-to-bottom button
          if (_showScrollDownButton)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.green,
                child: const Icon(Icons.arrow_downward),
                onPressed: _scrollToBottom,
              ),
            ),
        ],
      ),
    );
  }
}
