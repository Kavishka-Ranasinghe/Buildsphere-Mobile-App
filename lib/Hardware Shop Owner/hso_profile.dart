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
  String? _selectedDistrict;
  String? _selectedCity;
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
      final data = userDoc.data() as Map<String, dynamic>;

      setState(() {
        _nameController.text = data['shopName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _mapLinkController.text = data['mapLink'] ?? '';
        _downloadURL = data['profileImage'];
        _selectedDistrict = data['district'] ?? null;
        _selectedCity = data['city'] ?? null;
      });

      if (_downloadURL != null) {
        await _cacheProfileImage(_downloadURL!);
      }
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
        final updatedPhone = _phoneController.text.trim();
        final updatedShopName = _nameController.text.trim();
        final updatedAddress = _addressController.text.trim();
        final updatedDistrict = _selectedDistrict;
        final updatedCity = _selectedCity;

        // Update user's profile
        await FirebaseFirestore.instance.collection('users').doc(_userId).update({
          'shopName': updatedShopName,
          'email': _emailController.text.trim(),
          'phone': updatedPhone,
          'address': updatedAddress,
          'mapLink': _mapLinkController.text.trim(),
          'district': updatedDistrict,
          'city': updatedCity,
        });

        // ✅ Update all products posted by this user with the new phone number
        final productsRef = FirebaseFirestore.instance.collection('products');
        final querySnapshot = await productsRef.where('ownerId', isEqualTo: _userId).get();

        final batch = FirebaseFirestore.instance.batch();
        for (var doc in querySnapshot.docs) {
          batch.update(doc.reference, {
            'ownerTel': updatedPhone,
            'shopName': updatedShopName,
            'address': updatedAddress,
            'district': updatedDistrict,
            'town': updatedCity,
          });
        }
        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile  updated successfully")),
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

      // 1. Re-authentication (Password Prompt)
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: await _promptForPassword(),
      );
      await user.reauthenticateWithCredential(cred);

      // 2. Delete all user's products
      final productDocs = await FirebaseFirestore.instance
          .collection('products')
          .where('ownerId', isEqualTo: _userId)
          .get();
      for (var doc in productDocs.docs) {
        await doc.reference.delete();
      }

      // 3. Delete user document from Firestore
      await FirebaseFirestore.instance.collection('users').doc(_userId).delete();

      // 4. Delete profile image from Storage
      if (_downloadURL != null) {
        try {
          await FirebaseStorage.instance
              .ref('profile_images/$_userId/profile.jpg')
              .delete();
        } catch (e) {
          print("No profile image found or already deleted.");
        }
      }

      // 5. Delete from Firebase Auth
      await user.delete();

      // 6. Redirect to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );

      // 6. Show success popup and redirect
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text("Account Deleted ✅"),
            content: const Text(
              "Thank you for choosing us! 🏗️💚\nHope you will come back again! 👋😊",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                  );
                },
              ),
            ],
          );
        },
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
                        readOnly: true, // ✅ Make it read-only
                        enabled: false, // ❌ Prevent editing
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
                      const SizedBox(height: 10),
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

