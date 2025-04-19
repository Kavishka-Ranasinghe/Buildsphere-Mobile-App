//  better_player included
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:cometchat_sdk/models/action.dart' as cometchat;
import 'package:intl/intl.dart';
import 'group_info_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'pdf_viewer_page.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
<<<<<<< HEAD
import 'package:connectivity_plus/connectivity_plus.dart';
import '../no_internet_screen.dart';

=======
import 'package:better_player/better_player.dart';
>>>>>>> parent of 722ddc7 (Revert "better_player - to view video")


class VideoPlayerView extends StatefulWidget {
  final String url;

  const VideoPlayerView({super.key, required this.url});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  BetterPlayerController? _betterPlayerController;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadVideo();
    _checkInternet();
=======
    _setupBetterPlayer();
>>>>>>> parent of 722ddc7 (Revert "better_player - to view video")
  }

  Future<void> _setupBetterPlayer() async {
    try {
      final filename = path.basename(widget.url);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');

      if (!await file.exists()) {
        final response = await http.get(Uri.parse(widget.url));
        await file.writeAsBytes(response.bodyBytes);
      }

      final fileSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        file.path,
      );

      _betterPlayerController = BetterPlayerController(
        const BetterPlayerConfiguration(
          autoPlay: false,
          aspectRatio: 16 / 9,
          fit: BoxFit.contain,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableFullscreen: true,
            enableSkips: true,
          ),
        ),
        betterPlayerDataSource: fileSource,
      );


      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("⚠️ Error setting up better player: $e");
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }





  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ Center video content
          Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(controller: _betterPlayerController!),
            ),
          ),

          // ✅ Back button (top-left)
          Positioned(
            top: 20,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





class ChatScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}
class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
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
      ..limit = 30).build();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      // Load older messages when near the top of reversed list
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingOldMessages) {
        loadOlderMessages();
      }

      const scrollThreshold = 200.0;

      // ✅ Detect if user is away from bottom
      final isAtBottom = _scrollController.offset <= scrollThreshold;

      if (!isAtBottom && !_showScrollDownButton) {
        setState(() => _showScrollDownButton = true);
      } else if (isAtBottom && _showScrollDownButton) {
        setState(() => _showScrollDownButton = false);
      }
    });



    fetchMessages();
    CometChat.addMessageListener("chat_listener", this);
  }

  @override
  void dispose() {
    CometChat.removeMessageListener("chat_listener");
    _messagesRequest = null;
    _scrollController.dispose();
    super.dispose();
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
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }


  @override
  void onTextMessageReceived(TextMessage textMessage) {
    if (textMessage.receiverUid == widget.roomId) {
      final isNearBottom = _scrollController.hasClients &&
          _scrollController.offset >= _scrollController.position.maxScrollExtent - 400;

      setState(() {
        messages.insert(0, textMessage);
      });


      if (isNearBottom) {
        _scrollToBottom();
      }
    }
  }
  @override
  void onMediaMessageReceived(MediaMessage mediaMessage) {
    if (mediaMessage.receiverUid == widget.roomId) {
      final isNearBottom = _scrollController.hasClients &&
          _scrollController.offset >= _scrollController.position.maxScrollExtent - 400;

      setState(() {
        messages.insert(0, mediaMessage);
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
          messages.insert(0, sentMessage);
          _messageController.clear();
        });
        _scrollToBottom();
      },

      onError: (CometChatException e) {
        debugPrint("❌ Message sending failed: ${e.message}");
      },
    );
  }

  Future<void> pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;

      // ✅ Show uploading snackbar
      final snackBar = SnackBar(
        content: const Text("📤 Uploading media..."),
        duration: const Duration(days: 1), // Keep it visible until manually closed
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      MediaMessage mediaMessage = MediaMessage(
        receiverUid: widget.roomId,
        receiverType: CometChatReceiverType.group,
        file: filePath, // 🔥 fixed here
        type: CometChatMessageType.file,
      );

      CometChat.sendMediaMessage(
        mediaMessage,
        onSuccess: (BaseMessage sentMessage) {
          // ✅ Hide the uploading snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // ✅ Optionally show short success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Media uploaded"),
              duration: Duration(seconds: 2), // Auto-close after 2 seconds
            ),
          );

          setState(() {
            messages.insert(0, sentMessage);
          });
          _scrollToBottom();
        },

        onError: (CometChatException e) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar(); // ✅ Hide snack
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Upload failed: ${e.message}")),
          );
          debugPrint("❌ Failed to send file: ${e.message}");
        },
      );
    }
  }


  String formatTimeOnly(DateTime? timestamp) {
    if (timestamp == null) return "";
    return DateFormat('h:mm a').format(timestamp.toLocal());
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
                  padding: const EdgeInsets.only(bottom: 60),
                  child: ListView.builder(
                    reverse: true, // 👈 Important to show newest at bottom
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      BaseMessage message = messages[index];

                      return FutureBuilder<User?>(
                        future: CometChat.getLoggedInUser(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();

                          bool isSentByMe = message.sender?.uid == snapshot.data?.uid;

                          if (message is TextMessage) {
                            return _buildTextMessage(message, isSentByMe);
                          } else if (message is MediaMessage) {
                            return _buildMediaMessage(message, isSentByMe);
                          } else if (message is cometchat.Action) {
                            return _buildGroupAction(message);
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
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: pickAndSendFile,
                    ),
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

  Widget _buildTextMessage(TextMessage message, bool isSentByMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // ✅ Show "you" if it's your message
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    isSentByMe ? "you" : (message.sender?.name ?? "Unknown"),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSentByMe ? Colors.blueAccent : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatTimeOnly(message.sentAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSentByMe ? Colors.white70 : Colors.black54,
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
  }


  Widget _buildMediaMessage(MediaMessage message, bool isSentByMe) {
    final fileUrl = message.attachment?.fileUrl;
    final fileName = message.attachment?.fileName?.toLowerCase() ?? "";
    final isVideo = fileName.endsWith(".mp4");
    final isDoc = fileName.endsWith(".doc") || fileName.endsWith(".docx");
    final isPpt = fileName.endsWith(".ppt") || fileName.endsWith(".pptx");
    final isImage = fileName.endsWith(".jpg") || fileName.endsWith(".jpeg") ||
        fileName.endsWith(".png") || fileName.endsWith(".gif");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // ✅ Sender name or "you"
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    isSentByMe ? "you" : (message.sender?.name ?? "Unknown"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                onTap: () {
                  if (isImage && fileUrl != null) {
                    Navigator.push(context, MaterialPageRoute(
                    builder: (_) => FullScreenImageView(imageUrl: fileUrl),
                    ));
                  } else if (fileUrl != null && fileName.endsWith(".pdf")) {
                    Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PdfViewerPage(url: fileUrl, fileName: fileName),
                    ));
                  } else if (fileUrl != null && isVideo) {
                    Navigator.push(context, MaterialPageRoute(
                    builder: (_) => VideoPlayerView(url: fileUrl),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Preview not available for this file")),
                    );
                  }
                },


                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSentByMe ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isImage && fileUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: fileUrl,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                      ),
                    )
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          color: isSentByMe ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fileName,
                          style: TextStyle(
                            color: isSentByMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  formatTimeOnly(message.sentAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSentByMe ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildGroupAction(cometchat.Action message) {
    final actionType = message.action?.toLowerCase();
    if (actionType == "leave" || actionType == "kick" || actionType == "ban") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text("⚠️ ${message.message}", style: const TextStyle(color: Colors.grey)),
        ),
      );
    }
    return const SizedBox();
  }
}
