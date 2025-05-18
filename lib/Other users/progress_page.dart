import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class ProgressPage extends StatefulWidget {
  final String roomId;

  const ProgressPage({super.key, required this.roomId});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mapLinkController = TextEditingController();
  bool _isAdmin = false;
  bool _isLoading = true;
  User? currentUser;
  Group? group;
  Map<String, dynamic>? projectData;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserAndGroup();
    _fetchProjectData();
  }

  Future<void> _fetchCurrentUserAndGroup() async {
    currentUser = await CometChat.getLoggedInUser();
    await CometChat.getGroup(
      widget.roomId,
      onSuccess: (Group fetchedGroup) {
        setState(() {
          group = fetchedGroup;
          _isAdmin = currentUser?.uid == group?.owner;
          _isLoading = false;
        });
      },
      onError: (CometChatException e) {
        debugPrint("❌ Error fetching group: ${e.message}");
        setState(() => _isLoading = false);
      },
    );
  }

  Future<void> _fetchProjectData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('project_progress')
          .doc(widget.roomId)
          .get();

      if (doc.exists) {
        setState(() {
          projectData = doc.data() as Map<String, dynamic>;
          _descriptionController.text = projectData!['description'] ?? '';
          _mapLinkController.text = projectData!['mapLink'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching project data: $e");
    }
  }

  Future<void> _saveProjectData() async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception("User not authenticated");
      }

      await FirebaseFirestore.instance
          .collection('project_progress')
          .doc(widget.roomId)
          .set({
        'roomId': widget.roomId,
        'description': _descriptionController.text.trim(),
        'mapLink': _mapLinkController.text.trim(),
        'createdAt': Timestamp.now(),
        'createdBy': firebaseUser.uid, // Add the Firebase UID of the user
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Project progress updated successfully")),
      );
      await _fetchProjectData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving project data: $e")),
      );
    }
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return "N/A";
    return DateFormat('yyyy-MM-dd – h:mm a').format(timestamp.toDate());
  }

  String? _validateMapLink(String? value) {
    if (value != null && value.isNotEmpty) {
      final regex = RegExp(r'^https?:\/\/(www\.)?maps\.app\.goo\.gl\/');
      if (!regex.hasMatch(value)) {
        return 'Please enter a valid Google Maps link';
      }
    }
    return null;
  }

  Future<void> _launchMapLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $url")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Progress'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Details',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              readOnly: !_isAdmin,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Project Description',
                border: OutlineInputBorder(),
                hintText: _isAdmin
                    ? 'Enter project description'
                    : 'No description available',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _mapLinkController,
              readOnly: !_isAdmin,
              decoration: InputDecoration(
                labelText: 'Google Maps Link',
                border: OutlineInputBorder(),
                hintText: _isAdmin
                    ? 'Enter Google Maps link'
                    : 'No map link available',
                errorText: _validateMapLink(_mapLinkController.text),
              ),
              onTap: () {
                if (!_isAdmin && _mapLinkController.text.isNotEmpty) {
                  _launchMapLink(_mapLinkController.text);
                }
              },
            ),
            if (projectData != null) ...[
              const SizedBox(height: 20),
              Text(
                'Last Updated: ${formatDateTime(projectData!['createdAt'] as Timestamp?)}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
            if (_isAdmin)
              ElevatedButton(
                onPressed: _saveProjectData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Changes'),
              ),
          ],
        ),
      ),
    );
  }
}