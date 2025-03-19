import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../login.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

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
  final TextEditingController _mapLinkController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  File? _profileImage;
  String _userId = "";
  String? _downloadURL;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _userId = user.uid;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();

    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc['shopName'] ?? '';
        _emailController.text = userDoc['email'] ?? '';
        _phoneController.text = userDoc['phone'] ?? '';
        _addressController.text = userDoc['address'] ?? '';
        _mapLinkController.text = userDoc['mapLink'] ?? '';
        _downloadURL = userDoc['profileImage'];
        _cacheProfileImage(_downloadURL!);
      });
    }
  }
  Future<void> _cacheProfileImage(String imageUrl) async {
    final directory = await getApplicationDocumentsDirectory();
    final localPath = '${directory.path}/profile_$_userId.jpg';

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        File file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localImagePath = localPath;
        });
      }
    } catch (e) {
      print("Failed to cache image: $e");
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(_userId).update({
          'shopName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'mapLink': _mapLinkController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating profile: $e")),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File newImage = File(pickedFile.path);
      setState(() {
        _profileImage = newImage;
      });
      await _uploadProfileImage(newImage);
    }
  }
  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User is not logged in! Please sign in again.")),
        );
        return;
      }

      String userId = user.uid;
      String fileName = "profile.jpg";
      String filePath = 'profile_images/$userId/$fileName';

      List<int> imageBytes = await imageFile.readAsBytes();
      img.Image? decodedImage = img.decodeImage(Uint8List.fromList(imageBytes));

      if (decodedImage != null) {
        img.Image resizedImage = img.copyResize(decodedImage, width: 300);
        imageBytes = img.encodeJpg(resizedImage, quality: 80);
      }

      Reference ref = FirebaseStorage.instance.ref(filePath);
      UploadTask uploadTask = ref.putData(Uint8List.fromList(imageBytes));

      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        String imageURL = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'profileImage': imageURL,
        });

        setState(() {
          _downloadURL = imageURL;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully!")),
        );
      } else {
        throw Exception("Image upload failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
    }
  }
  Future<void> _deleteProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String filePath = 'profile_images/$_userId/profile.jpg';

      await Future.wait([
        FirebaseStorage.instance.ref(filePath).delete(),
        FirebaseFirestore.instance.collection('users').doc(_userId).update({
          'profileImage': FieldValue.delete(),
        }),
      ]);

      setState(() {
        _downloadURL = null;
        _profileImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture removed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete profile image: $e")),
      );
    }
  }
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }
  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              panEnabled: true,
              child: _profileImage != null
                  ? Image.file(_profileImage!)
                  : _downloadURL != null
                  ? CachedNetworkImage(imageUrl: _downloadURL!)
                  : const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _confirmDelete();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      _userId = user.uid;

      await FirebaseFirestore.instance.collection('users').doc(_userId).delete();
      if (_downloadURL != null) {
        try {
          await FirebaseStorage.instance.ref('profile_pictures/$_userId.jpg').delete();
        } catch (e) {
          print("No profile picture found to delete.");
        }
      }
      await user.delete();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting account: $e")),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Hardware Shop Owner Profile'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/modern.png', // ✅ Replace with your background image
              fit: BoxFit.cover,
            ),
          ),
          // Overlay for readability
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75), // ✅ Slight transparency for form
                  borderRadius: BorderRadius.circular(15), // ✅ Rounded borders
                  border: Border.all(color: Colors.green, width: 2), // ✅ Added border
                ),
                padding: const EdgeInsets.all(20),
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
                          onTap: _pickImage, // ✅ Short tap to pick image
                          onLongPress: () {  // ✅ Long press to view image full-screen
                            if (_profileImage != null || _downloadURL != null) {
                              _showFullScreenImage(context);
                            }
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!) // ✅ Show selected image
                                : _downloadURL != null
                                ? CachedNetworkImageProvider(_downloadURL!)
                                : const AssetImage('assets/images/profile.gif') as ImageProvider,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_downloadURL != null || _profileImage != null) // ✅ Only show if an image exists
                        Center(
                            child: TextButton(
                              onPressed: _deleteProfileImage,
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text("Remove Profile Picture"),
                          ),
                        ),

                      const SizedBox(height: 10),
                      if (_downloadURL == null && _localImagePath == null)
                        const Center(
                          child: Text(
                            'Please upload a profile picture.',
                            style: TextStyle(color: Colors.red, fontSize: 16),
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
                        controller: _mapLinkController,
                        decoration: const InputDecoration(
                          labelText: 'Google Maps Link',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                        validator: _validateMapLink,
                      ),
                      // ✅ Buttons
                      ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Save Changes'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _deleteAccount(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                        icon: const Icon(Icons.delete_forever, color: Colors.white),
                        label: const Text('Delete Account', style: TextStyle(color: Colors.white)),
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
            ),
          ),
        ],
      ),
    );
  }
}
Widget _buildDropdown({
  required String hint,
  required String? value,
  required List<String> items,
  required void Function(String?) onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    hint: Text(hint),
    isExpanded: true,
    items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
    onChanged: onChanged,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}

