import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_drawer.dart';  // Assuming you have an AppDrawer widget.

class ShopDetailScreen extends StatelessWidget {
  final String shopName;
  final String shopAddress;
  final String contactNumber;
  final String? googleMapLink;

  const ShopDetailScreen({
    super.key,
    required this.shopName,
    required this.shopAddress,
    required this.contactNumber,
    this.googleMapLink = "https://maps.app.goo.gl/5bcF7PPB1ji3Z6kG9", // Default Google Map link
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

  // Function to open Google Maps
  void _openGoogleMaps(BuildContext context, String url) async {
    final Uri googleMapsUri = Uri.parse(url);

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
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
            Navigator.pop(context); // Navigate back
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
              child: Image.asset(
                'assets/images/h_shop.jpg', // Use the same background image
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
            const SizedBox(height: 10),

            // Google Maps Section (Whole row clickable)
            GestureDetector(
              onTap: googleMapLink != null && googleMapLink!.isNotEmpty
                  ? () => _openGoogleMaps(context, googleMapLink!)
                  : null,
              child: Row(
                children: [
                  Icon(Icons.location_pin, color: Colors.red, size: 30),
                  const SizedBox(width: 8),
                  googleMapLink != null && googleMapLink!.isNotEmpty
                      ? Text(
                    'View on Google Maps',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  )
                      : const Text(
                    'Location not given',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
