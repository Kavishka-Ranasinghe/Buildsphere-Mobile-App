import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'c_shop_detail.dart';

class RawItemDetailScreen extends StatelessWidget {
  final String itemName;
  final String itemType;
  final String price;
  final String shopName;
  final String shopAddress;
  final String contactNumber;

  const RawItemDetailScreen({
    super.key,
    required this.itemName,
    required this.itemType,
    required this.price,
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
        title: const Text('Item Details'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/item_placeholder.png', // Placeholder image
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Item Name: $itemName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Item Type: $itemType', style: const TextStyle(fontSize: 16)),
            Text('Price: $price', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopDetailScreen(
                      shopName: shopName,
                      shopAddress: shopAddress,
                      contactNumber: contactNumber,
                    ),
                  ),
                );
              },
              child: Text(
                'Shop: $shopName',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Shop Address: $shopAddress', style: const TextStyle(fontSize: 16)),
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
