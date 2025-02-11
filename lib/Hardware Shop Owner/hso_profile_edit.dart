import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../login.dart'; // Import the Login Page

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mapLinkController = TextEditingController(); // New Google Maps link controller
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      }
    });
  }

  // Function to log out and redirect to login page
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  // Function to delete profile
  void _deleteProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Profile"),
          content: const Text("Are you sure you want to delete your profile? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile deleted successfully")),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Function to validate Google Maps link
  String? _validateMapLink(String? value) {
    if (value != null && value.isNotEmpty) {
      final regex = RegExp(r'^https?:\/\/(www\.)?maps\.app\.goo\.gl\/');
      if (!regex.hasMatch(value)) {
        return 'Please enter a valid Google Maps link';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/images/profile.gif') as ImageProvider,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Tap to change profile picture',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Shop Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Shop Tel Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Shop Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _mapLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Google Maps Link',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  validator: _validateMapLink,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profile updated")),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
