import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'hso_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedCategory;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? userDistrict;
  String? userTown;
  String? ownerPhone;
  String? shopName;
  String? shopAddress;
  String? Description;





  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<bool> _validateLocationBeforeAdd() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();

      if (data == null ||
          !(data.containsKey('district') && data.containsKey('city') && data.containsKey('phone') && data.containsKey('shopName') && data.containsKey('address')) ||
          (data['district'] as String?)?.isEmpty != false ||
          (data['city'] as String?)?.isEmpty != false ||
          (data['phone'] as String?)?.isEmpty != false ||
          (data['shopName'] as String?)?.isEmpty != false ||
         // (data['description'] as String?)?.isEmpty != false ||
          (data['address'] as String?)?.isEmpty != false) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Profile Incomplete"),
            content: const Text("Please complete your profile with District, City, Phone, Shop Name, and Shop Address."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HardwareShopOwnerPage()),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return false;
      }

      userDistrict = data['district'];
      userTown = data['city'];
      ownerPhone = data['phone'];
      shopName = data['shopName'];
      shopAddress = data['address'];
      Description = data['description'];

      return true;
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Failed to fetch your profile data. Please check your internet or try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return false;
    }
  }

  Future<void> _saveProduct() async {
    if (_image == null ||
        selectedCategory == null ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields and upload an image.")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Please wait..."),
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text("Uploading product...")),
          ],
        ),
      ),
    );

    try {
      User? user = FirebaseAuth.instance.currentUser;
      final isValid = await _validateLocationBeforeAdd();
      if (!isValid) return;
      if (user == null) throw Exception("User not logged in.");

      String filePath = 'products/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = FirebaseStorage.instance.ref(filePath).putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('products').add({
        'ownerId': user.uid,
        'name': nameController.text.trim(),
        'price': priceController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': selectedCategory,
        'imageUrl': imageUrl,
        'district': userDistrict,
        'town': userTown,
        'ownerTel': ownerPhone,
        'shopName': shopName,
        'address': shopAddress,
        'createdAt': Timestamp.now(),
      });

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success 🎉"),
          content: const Text("Product added successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HardwareShopOwnerPage()),
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add product: $e")),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Makes app bar float over background
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.green.withOpacity(0.8),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/modern.png', // Replace with your background image
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay for readability
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 80), // Space for floating app bar

                  // Modern Card Container
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    color: Colors.white.withOpacity(0.85),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Upload Section
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: _image != null ? FileImage(_image!) : null,
                                  child: _image == null
                                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              'Tap to upload a product image',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Category Selector
                          const Text("Select Category", style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            items: ['Cement', 'Sand', 'Bricks','Gravel','Concrete mix','Steel bars','Wood','Roofing sheets','PVC pipes and fittings','Electrical cables','Paint','Wall Putty']
                                .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                          ),
                          const SizedBox(height: 10),

                          // Product Name Input
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Product Name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Price Input
                          TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Price (LKR)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Product Description Input
                          TextField(
                            controller: descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Product Description',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Save Product Button
                          Center(
                            child: ElevatedButton(
                              onPressed: _saveProduct,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              ),
                              child: const Text('Add Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
