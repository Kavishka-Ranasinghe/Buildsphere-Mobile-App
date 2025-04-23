import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../login.dart'; // Import the Login Page
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cometchat_sdk/cometchat_sdk.dart' as comet_chat;
import 'package:http/http.dart' as http;






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
  String? _selectedDistrict;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
// Function to delete user account
  Future<void> _deleteAccount(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
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

      // 🔒 Step 1: Re-authenticate
      final password = await _promptForPassword();
      final cred = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);

      // 🗑️ Step 2: Delete Firestore document
      await FirebaseFirestore.instance.collection('users').doc(_userId).delete();

      // 🧹 Step 3: Delete profile picture (if any)
      if (_downloadURL != null) {
        try {
          await FirebaseStorage.instance.ref('profile_images/$_userId/profile.jpg').delete();
        } catch (e) {
          debugPrint("No profile image found or already deleted.");
        }
      }

      Future<void> deleteCometChatUser(String uid) async {
        const String appId = "272345917d37d43c";
        const String region = "in"; // From CometChat dashboard
        const String adminApiKey = "ce9288c50229728cde6a4a18c2d4075c0eb785ea";

        final Uri url = Uri.parse("https://$appId.api-$region.cometchat.io/v3/users/$uid");

        final response = await http.delete(
          url,
          headers: {
            'accept': 'application/json',
            'appId': appId,
            'apiKey': adminApiKey,
          },
        );

        if (response.statusCode == 200) {
          debugPrint("✅ CometChat user $uid deleted successfully.");
        } else {
          debugPrint("❌ Failed to delete CometChat user: ${response.statusCode} ${response.body}");
        }
      }




      // 🔥 Step 4: Delete from Firebase Auth
      await user.delete();

      await deleteCometChatUser(_userId);



      // 🎉 Step 5: Show farewell popup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Account Deleted 🎉"),
          content: const Text(
            "Thank you for choosing us! 🛠️💚\nWe hope to see you again someday! 👋🙂",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close popup
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );
    }
  }
  Future<String> _promptForPassword() async {
    String password = '';
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _passwordController = TextEditingController();
        return AlertDialog(
          title: const Text('Re-authentication Required'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Enter your password'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                password = _passwordController.text.trim();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return password;
  }

  // Function to delete profile image
  Future<void> _deleteProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User is not logged in!")),
        );
        return;
      }

      String userId = user.uid;
      String filePath = 'profile_images/$userId/profile.jpg';

      // ✅ Remove image reference from Firestore & Storage together
      await Future.wait([
        FirebaseStorage.instance.ref(filePath).delete(),
        FirebaseFirestore.instance.collection('users').doc(userId).update({
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




  // Function to load user data from Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'];
          _emailController.text = userDoc['email'];
          _userRole = userDoc['role'];
          _selectedDistrict = userDoc['district'];
          _selectedCity = userDoc['city'];
          _downloadURL = userDoc['profileImage'];

          // ✅ Save Image Locally
          _cacheProfileImage(_downloadURL!);
        });
      }
    }
  }


  // ✅ Save Image Locally
  Future<void> _cacheProfileImage(String imageUrl) async {
    final directory = await getApplicationDocumentsDirectory();
    final localPath = '${directory.path}/profile_$_userId.jpg';

    try {
      final response = await http.get(Uri.parse(imageUrl));  // ✅ Use `http.get()`
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









  // Function to pick an image and save it locally
  // Function to pick an image and update UI immediately
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File newImage = File(pickedFile.path);

      // ✅ Update UI immediately with selected image
      setState(() {
        _profileImage = newImage;
      });

      // ✅ Upload image to Firebase Storage
      await _uploadProfileImage(newImage);
    }
  }


  // Upload profile image to Firebase Storage
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
      String fileName = "profile.jpg"; // Keeping it constant to replace old image
      String filePath = 'profile_images/$userId/$fileName';

      // ✅ Resize Image Before Uploading (Reduce File Size)
      List<int> imageBytes = await imageFile.readAsBytes();
      img.Image? decodedImage = img.decodeImage(Uint8List.fromList(imageBytes));

      if (decodedImage != null) {
        img.Image resizedImage = img.copyResize(decodedImage, width: 300); // Resizing to 300px
        imageBytes = img.encodeJpg(resizedImage, quality: 80); // Compressing
      }

      // ✅ Use putData() instead of putFile()
      Reference ref = FirebaseStorage.instance.ref(filePath);
      UploadTask uploadTask = ref.putData(Uint8List.fromList(imageBytes)); // Faster Upload

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
  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(), // ✅ Tap to close
            child: InteractiveViewer(
              panEnabled: true, // ✅ Allow zooming
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




  // Function to save updated user data
  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'district': _selectedDistrict,
        'city': _selectedCity,
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
    // ✅ CometChat Logout
    await comet_chat.CometChat.logout(
      onSuccess: (_) {
        debugPrint("✅ CometChat logout successful");
      },
      onError: (comet_chat.CometChatException e) {
        debugPrint("❌ CometChat logout failed: ${e.message}");
      },
    );

    // ✅ Firebase Logout
    await FirebaseAuth.instance.signOut();

    // ✅ Navigate to Login Screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }


  final List<String> districts = [
    'Colombo', 'Gampaha', 'Kalutara', 'Kandy', 'Matale', 'Nuwara Eliya',
    'Galle', 'Matara', 'Hambantota', 'Jaffna', 'Kilinochchi', 'Mannar', 'Vavuniya',
    'Mullaitivu', 'Batticaloa', 'Ampara', 'Trincomalee', 'Kurunegala', 'Puttalam',
    'Anuradhapura', 'Polonnaruwa', 'Badulla', 'Monaragala', 'Ratnapura', 'Kegalle'
  ];
  final Map<String, List<String>> cities = {
    'Colombo': ['Colombo 1', 'Colombo 2', 'Colombo 3', 'Nugegoda', 'Dehiwala', 'Maharagama', 'Piliyandala', 'Homagama', 'Kottawa', 'Battaramulla', 'Koswatta'],
    'Gampaha': ['Negombo', 'Gampaha', 'Ja-Ela', 'Wattala', 'Minuwangoda', 'Kelaniya', 'Ragama', 'Mirigama', 'Katunayake', 'Ganemulla'],
    'Kalutara': ['Kalutara', 'Panadura', 'Horana', 'Beruwala', 'Matugama', 'Aluthgama', 'Wadduwa', 'Ingiriya', 'Payagala', 'Bandaragama'],
    'Kandy': ['Kandy', 'Peradeniya', 'Katugastota', 'Gampola', 'Nawalapitiya', 'Wattegama', 'Digana', 'Pilimathalawa', 'Teldeniya', 'Kadugannawa'],
    'Matale': ['Matale', 'Dambulla', 'Galewela', 'Rattota', 'Ukuwela', 'Palapathwala', 'Laggala', 'Nalanda'],
    'Nuwara Eliya': ['Nuwara Eliya', 'Hatton', 'Ginigathhena', 'Kotagala', 'Talawakelle', 'Ragala', 'Pundaluoya', 'Dayagama'],
    'Galle': ['Galle', 'Hikkaduwa', 'Unawatuna', 'Ambalangoda', 'Karapitiya', 'Weligama', 'Ahangama', 'Bentota', 'Koggala', 'Balapitiya'],
    'Matara': ['Matara', 'Weligama', 'Akurassa', 'Deniyaya', 'Hakmana', 'Dikwella', 'Kamburugamuwa', 'Devinuwara', 'Weeraketiya'],
    'Hambantota': ['Hambantota', 'Tangalle', 'Beliatta', 'Tissamaharama', 'Sooriyawewa', 'Weerawila', 'Lunugamvehera', 'Kirinda'],
    'Jaffna': ['Jaffna', 'Nallur', 'Point Pedro', 'Chavakachcheri', 'Kopay', 'Atchuvely', 'Karainagar', 'Kankesanthurai', 'Velanai'],
    'Kilinochchi': ['Kilinochchi', 'Pallai', 'Paranthan', 'Mallavi', 'Tharmapuram', 'Kandavalai'],
    'Mannar': ['Mannar', 'Murunkan', 'Pesalai', 'Thalaimannar', 'Madhu'],
    'Vavuniya': ['Vavuniya', 'Nedunkeni', 'Omanthai', 'Cheddikulam', 'Parayanalankulam'],
    'Mullaitivu': ['Mullaitivu', 'Puthukudiyiruppu', 'Oddusuddan', 'Maritimepattu', 'Thunukkai'],
    'Batticaloa': ['Batticaloa', 'Kaluwanchikudy', 'Eravur', 'Valachchenai', 'Kattankudy', 'Chenkalady', 'Vakarai'],
    'Ampara': ['Ampara', 'Kalmunai', 'Sainthamaruthu', 'Akkaraipattu', 'Sammanthurai', 'Dehiattakandiya', 'Uhana'],
    'Trincomalee': ['Trincomalee', 'Kinniya', 'Mutur', 'Nilaveli', 'Kantale', 'China Bay'],
    'Kurunegala': ['Kurunegala', 'Kuliyapitiya', 'Pannala', 'Mawathagama', 'Narammala', 'Alawwa', 'Polgahawela', 'Wariyapola', 'Nikaweratiya', 'Galgamuwa'],
    'Puttalam': ['Puttalam', 'Chilaw', 'Wennappuwa', 'Nattandiya', 'Marawila', 'Anamaduwa', 'Madampe'],
    'Anuradhapura': ['Anuradhapura', 'Kekirawa', 'Mihintale', 'Thambuttegama', 'Eppawala', 'Nochchiyagama'],
    'Polonnaruwa': ['Polonnaruwa', 'Hingurakgoda', 'Medirigiriya', 'Dimbulagala'],
    'Badulla': ['Badulla', 'Bandarawela', 'Haputale', 'Welimada', 'Mahiyanganaya', 'Diyatalawa', 'Passara'],
    'Monaragala': ['Monaragala', 'Wellawaya', 'Bibile', 'Medagama', 'Siyambalanduwa'],
    'Ratnapura': ['Ratnapura', 'Embilipitiya', 'Pelmadulla', 'Balangoda', 'Eheliyagoda', 'Kuruwita', 'Opanayaka'],
    'Kegalle': ['Kegalle', 'Mawanella', 'Warakapola', 'Ruwanwella', 'Dehiowita', 'Deraniyagala'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Background Image with Blur Effect
          Positioned.fill(
            child: Image.asset(
              'assets/images/modern.png', // Add this image to assets folder
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3), // Dark overlay
            ),
          ),
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Slightly transparent white background
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green, width: 5), // ✅ Added green border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Profile',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),


                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
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
                            const SizedBox(height: 10),

                            if (_downloadURL != null || _profileImage != null) // ✅ Only show if an image exists
                              TextButton(
                                onPressed: _deleteProfileImage,
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text("Remove Profile Picture"),
                              ),
                          ],
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

                      // Display Role as Read-Only Text
                      Text(
                        'Selected Role: $_userRole',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

                      // ✅ District Dropdown
                      _buildDropdown(
                        hint: "Select District",
                        value: _selectedDistrict,
                        items: districts,
                        onChanged: (value) {
                          setState(() {
                            _selectedDistrict = value;
                            _selectedCity = null; // Reset city
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      // ✅ City Dropdown (only if district is selected)
                      if (_selectedDistrict != null)
                        _buildDropdown(
                          hint: "Select City",
                          value: _selectedCity,
                          items: cities[_selectedDistrict!] ?? [],
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                            });
                          },
                        ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: _saveChanges,
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

