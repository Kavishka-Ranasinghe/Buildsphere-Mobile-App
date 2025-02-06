import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> material;

  const EditProductPage({super.key, required this.material});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  File? _image;
  String? _existingImageUrl; // This stores the existing image URL from the database

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.material['name'] ?? '');
    priceController = TextEditingController(text: widget.material['price']?.toString() ?? '0');

    // Fetch the existing image URL (it will be a file path or Firebase URL later)
    _existingImageUrl = widget.material['image'];
    _image = null; // No new image picked yet
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

  void _saveChanges() {
    Navigator.pop(context, {
      'name': nameController.text,
      'price': priceController.text.isNotEmpty ? priceController.text : '0',
      'image': _image?.path ?? _existingImageUrl, // Keep existing image if no new one is picked
    });
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
