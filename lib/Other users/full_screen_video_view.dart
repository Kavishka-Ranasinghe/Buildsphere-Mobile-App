import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class FullScreenVideoView extends StatefulWidget {
  final String url;

  const FullScreenVideoView({super.key, required this.url});

  @override
  State<FullScreenVideoView> createState() => _FullScreenVideoViewState();
}

class _FullScreenVideoViewState extends State<FullScreenVideoView> {
  late VideoPlayerController _controller;
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
        _controller = VideoPlayerController.file(file);
      } else {
        final response = await http.get(Uri.parse(widget.url));
        await file.writeAsBytes(response.bodyBytes);
        _controller = VideoPlayerController.file(file);
      }

      await _controller.initialize();

      // ✅ Wait for one frame to get real size from the renderer
      await Future.delayed(const Duration(milliseconds: 50));
      final resolution = _controller.value.size;
      final aspect = _controller.value.aspectRatio;

      debugPrint("✅ Accurate Video Size: ${resolution.width.toInt()} x ${resolution.height.toInt()}");
      debugPrint("✅ Actual Aspect Ratio: $aspect");

      setState(() {
        _isLoading = false;
      });
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
    final pos = _controller.value.position;
    final dur = _controller.value.duration;
    final next = pos + const Duration(seconds: 5);
    _controller.seekTo(next < dur ? next : dur);
  }

  void _skipBackward() {
    final pos = _controller.value.position;
    final back = pos - const Duration(seconds: 5);
    _controller.seekTo(back > Duration.zero ? back : Duration.zero);
  }

  Widget _buildVideo() {
    final Size videoSize = _controller.value.size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double videoWidth = videoSize.width;
    final double videoHeight = videoSize.height;

    final bool isPortrait = videoHeight > videoWidth;

    debugPrint("📏 Detected Size: $videoWidth x $videoHeight → ${isPortrait ? "Portrait" : "Landscape"}");

    // Fit video within screen, preserving original ratio
    final double displayWidth = screenWidth;
    final double displayHeight = (videoHeight / videoWidth) * displayWidth;

    return Center(
      child: SizedBox(
        width: displayWidth,
        height: displayHeight > screenHeight ? screenHeight : displayHeight,
        child: VideoPlayer(_controller),
      ),
    );
  }









  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
        body: Stack(
          children: [
            // Video or Loading
            Positioned.fill(
              child: _isLoading || !_controller.value.isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  _buildVideo(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 18,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          colors: const VideoProgressColors(
                            playedColor: Colors.blue,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.white30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_5, size: 36, color: Colors.white),
                            onPressed: _skipBackward,
                          ),
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                              size: 48,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlayback,
                          ),
                          IconButton(
                            icon: const Icon(Icons.forward_5, size: 36, color: Colors.white),
                            onPressed: _skipForward,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ],
              ),
            ),

            // 👈 Always visible back button (top-left corner)
            Positioned(
              top: 20,
              left: 10,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
    );
  }
}
