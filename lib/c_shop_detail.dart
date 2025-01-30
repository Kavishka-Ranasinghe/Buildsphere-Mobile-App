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

  // Function to launch the phone dialer
  void _callNumber(BuildContext context, String number) async {
    final Uri phoneUri = Uri.parse('tel:$number');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open dialer for $number')),
      );
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
            Navigator.pop(context);  // Navigate back
          },
        ),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
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

            // Shop Image (Placeholder)
            Center(
              child: Image.network(
                'https://via.placeholder.com/150',  // Placeholder image
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Shop details
            Text(
              'Shop Name: $shopName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Address: $shopAddress', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            // Contact number section (Clickable icon + text)
            GestureDetector(
              onTap: () => _callNumber(context, contactNumber), // Call function when tapped
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green, size: 30),
                    onPressed: () => _callNumber(context, contactNumber),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Contact: $contactNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
