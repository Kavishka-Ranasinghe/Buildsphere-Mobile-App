import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile.dart';
import '../app_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
// vision api key - AIzaSyDnCk4toEnmEBG90v6Gg22ioK2ZSoRpQbo




class ItemShoppingScreen extends StatefulWidget {
  const ItemShoppingScreen({super.key});

  @override
  State<ItemShoppingScreen> createState() => _ItemShoppingScreenState();
}

class _ItemShoppingScreenState extends State<ItemShoppingScreen> {

  final TextEditingController searchController = TextEditingController();

  Future<void> _scanItemWithVisionAPI(BuildContext context, File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      const String apiKey = 'AIzaSyDnCk4toEnmEBG90v6Gg22ioK2ZSoRpQbo'; // your API key
      final Uri url = Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

      print("📤 Sending request to Vision API...");
      print("🖼️ Base64 Image Size: ${base64Image.length}");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Please wait..."),
              ],
            ),
          );
        },
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requests": [
            {
              "image": {"content": base64Image},
              "features": [
                {"type": "LABEL_DETECTION", "maxResults": 5}
              ]
            }
          ]
        }),
      );


      print("✅ Response status: ${response.statusCode}");

      if (response.statusCode != 200) {
        print("❌ Vision API Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
        return;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final labels = data['responses'][0]['labelAnnotations'];

      if (labels == null || labels.isEmpty) {
        print("⚠️ No labels found in response.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No recognizable item found.")),
        );
        return;
      }

      final List<String> topLabels = labels
          .take(5)
          .map<String>((label) => label['description'] as String)
          .toList();

      print("🎯 Top Labels: $topLabels");
      if (Navigator.canPop(context)) Navigator.pop(context);

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Detected Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...topLabels.map((label) => ListTile(
                  title: Text(label),
                  onTap: () {
                    setState(() {
                      searchController.text = label;
                    });
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("❌ Exception in Vision API: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong.")),
      );
    }
  }








  // Function to search for an item
  void _searchItem(String query, BuildContext context) async {
    if (query.isEmpty) {
      // Show error if search field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an item to search."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final darazAppUrl = 'daraz://search?q=${Uri.encodeComponent(query)}'; // Daraz app deep link
    final darazWebUrl =
        'https://www.daraz.lk/catalog/?spm=a2a0e.tm80335410.search.d_go&q=${Uri.encodeComponent(query)}';

    if (await canLaunchUrl(Uri.parse(darazAppUrl))) {
      // If the Daraz app is installed, open the app
      await launchUrl(Uri.parse(darazAppUrl));
    } else {
      // If the Daraz app is not installed, open in a web browser
      await launchUrl(
        Uri.parse(darazWebUrl),
        mode: LaunchMode.externalApplication, // Ensures opening in a web browser
      );
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buildsphere',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Background Image with Blur Effect
          Positioned.fill(
            child: Image.asset(
              'assets/images/modern.png', // Ensure this image is in your assets folder
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Adds blur effect
              child: Container(
                color: Colors.black.withOpacity(0.2), // Slight dark overlay
              ),
            ),
          ),
          Column(
            children: [
              // Header with Profile Icon
              Container(
                color: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Item Shopping',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellowAccent,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/profile.gif'),
                        radius: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Centering the Search and Buttons
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, // Solid White Background
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green, width: 5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                labelText: 'Search for an item',
                                prefixIcon: Icon(Icons.search, color: Colors.black54),
                                border: InputBorder.none, // Remove default border
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              style: const TextStyle(color: Colors.black),
                              onSubmitted: (query) => _searchItem(query, context),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Buttons with Filled White Background
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFilledButton(
                                icon: Icons.search,
                                label: "Search",
                                onPressed: () {
                                  _searchItem(searchController.text, context);
                                },
                              ),
                              const SizedBox(width: 20),
                              _buildFilledButton(
                                icon: Icons.camera_alt,
                                label: "Scan Item",
                                onPressed: () async {
                                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                                  if (pickedFile != null) {
                                    final imageFile = File(pickedFile.path);
                                    _scanItemWithVisionAPI(context, imageFile); // ✅ now passing both args
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("No image selected.")),
                                    );
                                  }
                                },

                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilledButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black, // Button background color
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton.icon(
          icon: Icon(icon, color: Colors.black),
          label: Text(label, style: const TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // White background for button
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 2,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
