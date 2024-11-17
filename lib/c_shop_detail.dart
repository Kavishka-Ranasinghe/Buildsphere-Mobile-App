import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_drawer.dart';  // Assuming you have an AppDrawer widget.

class ShopDetailScreen extends StatelessWidget {
  final String shopName;
  final String shopAddress;
  final String contactNumber;

  const ShopDetailScreen({
    super.key,
    required this.shopName,
    required this.shopAddress,
    required this.contactNumber,
  });

  // Function to launch a phone call
  void _callNumber(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('Could not launch $number');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Details'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // This will take the user back to the previous page
          },
        ),
      ),
      drawer: const AppDrawer(),  // Assuming you have an AppDrawer widget to provide the navigation menu
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section without profile section
            Container(
              color: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Shop Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Placeholder image for the shop (Shop board)
            Center(
              child: Image.network(
                'https://via.placeholder.com/150',  // Placeholder image URL
                height: 150, // Adjust the height as needed
                width: 150,  // Adjust the width as needed
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Shop details content
            Text(
              'Shop Name: $shopName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Address: $shopAddress', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _callNumber(contactNumber),
              child: Text(
                'Contact: $contactNumber',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
