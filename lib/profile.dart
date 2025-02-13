import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'login.dart'; // Import the Login Page

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _userId = "";
  String _userRole = ""; // Store user role
  String? _localImagePath;
  String? _downloadURL; // 🔹 Ensure this is declared in the class

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load user data from Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get(const GetOptions(source: Source.server)); // ✅ Fetch fresh data

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'];
          _emailController.text = userDoc['email'];
          _userRole = userDoc['role'];
          _localImagePath = userDoc['localProfileImage'] ?? null;
          _downloadURL = userDoc['profileImage'] ?? null;
        });
      }
    }
  }

  // Function to pick an image and save it locally
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File newImage = File(pickedFile.path);

      // ✅ Save image locally
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/profile_${_userId}.jpg';
      final savedImage = await newImage.copy(localPath);

      setState(() {
        _profileImage = savedImage;
        _localImagePath = localPath;
      });

      // ✅ Upload image to Firebase Storage
      await _uploadProfileImage(savedImage);
    }
  }

  // Upload profile image to Firebase Storage
  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      String filePath = 'profile_pictures/$_userId.jpg';
      UploadTask uploadTask = FirebaseStorage.instance.ref(filePath).putFile(imageFile);

      await uploadTask; // ✅ Wait until the upload completes

      // ✅ Get Download URL
      String imageURL = await FirebaseStorage.instance.ref(filePath).getDownloadURL();

      setState(() {
        _localImagePath = imageFile.path; // ✅ Update local image path
        _downloadURL = imageURL; // ✅ Store Firebase URL
      });

      // ✅ Save paths to Firestore
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'localProfileImage': _localImagePath,
        'profileImage': imageURL, // ✅ Store Firebase URL as well
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
    }
  }

  // Function to save updated user data
  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  // Function to log out and redirect to login page
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _localImagePath != null
                        ? FileImage(File(_localImagePath!)) // ✅ Use Local Image
                        : _downloadURL != null
                        ? NetworkImage("$_downloadURL?t=${DateTime.now().millisecondsSinceEpoch}")
                        : const AssetImage('assets/images/profile.gif') as ImageProvider,
                  ),
                ),
              ),

              const SizedBox(height: 10),
              if (_downloadURL == null && _localImagePath == null) // ✅ Show this only if no image exists
                const Center(
                  child: Text(
                    'Please upload a profile picture.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              const SizedBox(height: 20),

              // Display Role as Read-Only Text
              Text(
                'Selected Role: $_userRole',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Name Input
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Email Input
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Save Changes'),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
