import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String fileName;

  const PdfViewerPage({super.key, required this.url, required this.fileName});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadAndSave();
  }

  Future<void> downloadAndSave() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/${widget.fileName}";
      final file = File(filePath);

      if (!await file.exists()) {
        await Dio().download(widget.url, filePath);
      }

      setState(() {
        localPath = filePath;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ PDF download error: $e");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.fileName)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
