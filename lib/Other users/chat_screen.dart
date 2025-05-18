import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:cometchat_sdk/models/action.dart' as cometchat;
import 'package:intl/intl.dart';
import 'group_info_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'pdf_viewer_page.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'progress_page.dart'; // Import the new progress page

class VideoPlayerView extends StatefulWidget {
  final String url;

  const VideoPlayerView({super.key, required this.url});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late vp.VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      final filename = path.basename(widget.url);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');

      if (await file.exists()) {
        _controller = vp.VideoPlayerController.file(file);
      } else {
        final response = await http.get(Uri.parse(widget.url));
        await file.writeAsBytes(response.bodyBytes);
        _controller = vp.VideoPlayerController.file(file);
      }

      await _controller.initialize();
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("⚠️ Error loading video: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  void _skipForward() {
    final current = _controller.value.position;
    final max = _controller.value.duration;
    final newPosition = current + const Duration(seconds: 5);
    if (newPosition < max) {
      _controller.seekTo(newPosition);
    } else {
      _controller.seekTo(max);
    }
  }

  void _skipBackward() {
    final current = _controller.value.position;
    final newPosition = current - const Duration(seconds: 5);
    _controller.seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  Widget _buildVideoPlayer() {
    final Size videoSize = _controller.value.size;
    final double aspectRatio = _controller.value.aspectRatio;

    final double maxWidth = MediaQuery.of(context).size.width * 1.5;
    final double maxHeight = MediaQuery.of(context).size.height * 0.8;

    double displayWidth = maxWidth;
    double displayHeight = displayWidth / aspectRatio;

    if (displayHeight > maxHeight) {
      displayHeight = maxHeight;
      displayWidth = displayHeight * aspectRatio;
    }

    return Center(
      child: Container(
        width: displayWidth,
        height: displayHeight,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: vp.VideoPlayer(_controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading || !_controller.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _buildVideoPlayer(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 15,
              child: vp.VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: vp.VideoProgressColors(
                  playedColor: Colors.blue,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.white30,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_5, size: 36, color: Colors.white),
                  onPressed: _skipBackward,
                ),
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: Colors.white,
                    size: 48,
                  ),
                  onPressed: _togglePlayback,
                ),
                IconButton(
                  icon: const Icon(Icons.forward_5, size: 36, color: Colors.white),
                  onPressed: _skipForward,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
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
  User? currentUser;
  Group? group;

  @override
  void initState() {
    super.initState();

    _messagesRequest = (MessagesRequestBuilder()
      ..guid = widget.roomId
      ..limit = 30)
        .build();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingOldMessages) {
        loadOlderMessages();
      }

      const scrollThreshold = 200.0;

      final isAtBottom = _scrollController.offset <= scrollThreshold;

      if (!isAtBottom && !_showScrollDownButton) {
        setState(() => _showScrollDownButton = true);
      } else if (isAtBottom && _showScrollDownButton) {
        setState(() => _showScrollDownButton = false);
      }
    });

    fetchMessages();
    fetchCurrentUser();
    fetchGroupInfo();
    CometChat.addMessageListener("chat_listener", this);
  }

  @override
  void dispose() {
    CometChat.removeMessageListener("chat_listener");
    _messagesRequest = null;
    _scrollController.dispose();
    super.dispose();
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

  Future<void> fetchCurrentUser() async {
    setState(() {
      currentUser = CometChat.getLoggedInUser() as User?;
    });
  }

  Future<void> fetchGroupInfo() async {
    try {
      await CometChat.getGroup(
        widget.roomId,
        onSuccess: (Group fetchedGroup) {
          setState(() {
            group = fetchedGroup;
          });
        },
        onError: (CometChatException e) {
          debugPrint("❌ Error fetching group: ${e.message}");
        },
      );
    } catch (e) {
      debugPrint("❌ Exception: $e");
    }
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

  @override
  void onMessageDeleted(BaseMessage message) {
    if (message.receiverUid == widget.roomId) {
      setState(() {
        final index = messages.indexWhere((msg) => msg.id == message.id);
        if (index != -1) {
          messages[index] = message;
        }
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
      String fileName = result.files.single.name.toLowerCase();
      String? caption;

      caption = await _showCaptionDialog();

      final snackBar = SnackBar(
        content: const Text("📤 Uploading media..."),
        duration: const Duration(days: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Map<String, dynamic> metadata = {};
      if (caption != null && caption.isNotEmpty) {
        metadata["caption"] = caption;
      }

      MediaMessage mediaMessage = MediaMessage(
        receiverUid: widget.roomId,
        receiverType: CometChatReceiverType.group,
        file: filePath,
        type: CometChatMessageType.file,
        metadata: metadata.isNotEmpty ? metadata : null,
      );

      CometChat.sendMediaMessage(
        mediaMessage,
        onSuccess: (BaseMessage sentMessage) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Media uploaded"),
              duration: Duration(seconds: 2),
            ),
          );

          setState(() {
            messages.insert(0, sentMessage);
          });
          _scrollToBottom();
        },
        onError: (CometChatException e) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Upload failed: ${e.message}")),
          );
          debugPrint("❌ Failed to send file: ${e.message}");
        },
      );
    }
  }

  Future<String?> _showCaptionDialog() async {
    final TextEditingController captionController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add a Caption"),
          content: TextField(
            controller: captionController,
            decoration: const InputDecoration(hintText: "Enter caption (optional)"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Skip"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, captionController.text),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  String formatTimeOnly(DateTime? timestamp) {
    if (timestamp == null) return "";
    return DateFormat('h:mm a').format(timestamp.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
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
            CometChatCallButtons(
              group: Group(
                guid: widget.roomId,
                name: widget.roomName,
                type: GroupTypeConstants.public,
              ),
              callButtonsStyle: CometChatCallButtonsStyle(
                voiceCallIconColor: Colors.green,
                videoCallIconColor: Colors.blue,
                voiceCallButtonColor: Colors.white,
                videoCallButtonColor: Colors.white,
                voiceCallButtonBorderRadius: BorderRadius.circular(12),
                videoCallButtonBorderRadius: BorderRadius.circular(12),
                voiceCallButtonBorder: BorderSide(color: Colors.grey, width: 1),
                videoCallButtonBorder: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgressPage(roomId: widget.roomId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Project Progress'),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      BaseMessage message = messages[index];

                      return FutureBuilder<User?>(
                        future: CometChat.getLoggedInUser(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || group == null) return const SizedBox();

                          bool isSentByMe = message.sender?.uid == snapshot.data?.uid;
                          bool isAdmin = snapshot.data?.uid == group?.owner;

                          if (message is TextMessage) {
                            return _buildTextMessage(message, isSentByMe, isAdmin);
                          } else if (message is MediaMessage) {
                            return _buildMediaMessage(message, isSentByMe, isAdmin);
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
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 1,
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

  Widget _buildTextMessage(TextMessage message, bool isSentByMe, bool isAdmin) {
    bool isDeleted = message.deletedAt != null;

    return GestureDetector(
      onLongPress: (isSentByMe || isAdmin) ? () => _showDeleteConfirmation(context, message.id) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
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
                        if (isDeleted)
                          const Text(
                            "message was deleted",
                            style: TextStyle(color: Colors.black, fontStyle: FontStyle.normal),
                          )
                        else
                          SelectableText(
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
      ),
    );
  }

  Widget _buildMediaMessage(MediaMessage message, bool isSentByMe, bool isAdmin) {
    bool isDeleted = message.deletedAt != null;
    final fileUrl = message.attachment?.fileUrl;
    final fileName = message.attachment?.fileName?.toLowerCase() ?? "";
    final isVideo = fileName.endsWith(".mp4");
    final isDoc = fileName.endsWith(".doc") || fileName.endsWith(".docx");
    final isPpt = fileName.endsWith(".ppt") || fileName.endsWith(".pptx");
    final isImage = fileName.endsWith(".jpg") ||
        fileName.endsWith(".jpeg") ||
        fileName.endsWith(".png") ||
        fileName.endsWith(".gif");

    String? caption;
    if (message.metadata != null && message.metadata!.containsKey("caption")) {
      caption = message.metadata!["caption"];
    }

    return GestureDetector(
      onLongPress: (isSentByMe || isAdmin) ? () => _showDeleteConfirmation(context, message.id) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      isSentByMe ? "you" : (message.sender?.name ?? "Unknown"),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isImage && fileUrl != null && !isDeleted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageView(imageUrl: fileUrl),
                          ),
                        );
                      } else if (fileUrl != null && fileName.endsWith(".pdf") && !isDeleted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewerPage(url: fileUrl, fileName: fileName),
                          ),
                        );
                      } else if (fileUrl != null && isVideo && !isDeleted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerView(url: fileUrl),
                          ),
                        );
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
                      child: isDeleted
                          ? const Text(
                        "message was deleted",
                        style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                      )
                          : isImage && fileUrl != null
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: fileUrl,
                              width: 280,
                              height: 280,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                            ),
                          ),
                          if (caption != null && caption.isNotEmpty) ...[
                            const SizedBox(height: 11),
                            SelectableText(
                              caption,
                              style: TextStyle(
                                color: isSentByMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ],
                      )
                          : isVideo
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/Video_icon.png',
                            width: 50,
                            height: 50,
                          ),
                          if (caption != null && caption.isNotEmpty) ...[
                            const SizedBox(height: 11),
                            SelectableText(
                              caption,
                              style: TextStyle(
                                color: isSentByMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                          if (caption != null && caption.isNotEmpty) ...[
                            const SizedBox(height: 11),
                            SelectableText(
                              caption,
                              style: TextStyle(
                                color: isSentByMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
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

  void _showDeleteConfirmation(BuildContext context, int messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Message"),
          content: const Text("Are you sure you want to delete this message?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await deleteMessage(messageId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await CometChat.deleteMessage(
        messageId,
        onSuccess: (BaseMessage message) {
          setState(() {
            final index = messages.indexWhere((msg) => msg.id == messageId);
            if (index != -1) {
              messages[index] = message;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Message deleted successfully")),
          );
        },
        onError: (CometChatException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete: ${e.message}")),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}