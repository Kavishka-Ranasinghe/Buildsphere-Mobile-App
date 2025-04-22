import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class EditProductPage extends StatefulWidget {
  final String productId;

  const EditProductPage({super.key, required this.productId});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}


class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  File? _image;
  String? _existingImageUrl; // Stores existing image URL from database
  bool _isLoading = true;


  Map<String, dynamic>? productData;
  late TextEditingController descriptionController;


  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }
  Future<void> _fetchProductData() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    if (doc.exists) {
      productData = doc.data();
      _existingImageUrl = productData?['imageUrl'];
      nameController = TextEditingController(text: productData?['name']);
      priceController = TextEditingController(text: productData?['price']);
      descriptionController = TextEditingController(text: productData?['description']);

      setState(() {
        _isLoading = false; // Now it's ready
      });
    }
  }


  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // New image picked
      });
    }
  }

  Future<void> _saveChanges() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Please wait..."),
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text("Updating product...")),
          ],
        ),
      ),
    );

    try {
      String? newImageUrl = _existingImageUrl;

      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref('products/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final upload = await ref.putFile(_image!);
        newImageUrl = await upload.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'name': nameController.text,
        'price': priceController.text,
        'description': descriptionController.text,
        'imageUrl': newImageUrl,
      });

      // Close loading
      Navigator.of(context).pop();

      // Show success dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success 🎉"),
          content: const Text("Product updated successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pop(context); // Go back to product list
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update product: $e")),
      );
    }
  }


  Future<void> _confirmDelete(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: const Text("Are you sure you want to delete this product? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // Close dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog first
                await _deleteProduct(); // Then proceed to delete
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .delete();

      Navigator.pop(context); // Exit edit screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
      return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: _image != null
                      ? Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover)
                      : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                      ? Image.network(_existingImageUrl!, height: 150, width: 150, fit: BoxFit.cover)
                      : Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                  )),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price (LKR)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () => _confirmDelete(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete Product'),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
