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
  final String imageUrl;
  final String description;

  const RawItemDetailScreen({
    super.key,
    required this.itemName,
    required this.itemType,
    required this.price,
    required this.shopName,
    required this.shopAddress,
    required this.contactNumber,
    required this.imageUrl,
    required this.description,
  });

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

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.8,
            maxScale: 5.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset('assets/images/item_placeholder.png'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? Colors.green, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Product Image (tap to zoom)
            GestureDetector(
              onTap: () => _showFullImage(context),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Image.asset('assets/images/item_placeholder.png', height: 220),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📦 Box 01: Item Info
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(icon: Icons.shopping_bag, label: 'Item Name', value: itemName),
                    _buildInfoCard(icon: Icons.category, label: 'Item Type', value: itemType),
                    _buildInfoCard(icon: Icons.price_change, label: 'Price', value: 'LKR $price'),
                    _buildInfoCard(
                      icon: Icons.description,
                      label: 'Description',
                      value: description,
                      iconColor: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🏬 Box 02: Shop Info
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop Name (Clickable)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.store, color: Colors.blue),
                      title: Text(
                        shopName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      subtitle: const Text("Tap to view shop details"),
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
                    ),
                    const SizedBox(height: 10),
                    // Contact
                    GestureDetector(
                      onTap: () => _callNumber(context, contactNumber),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.green),
                          const SizedBox(width: 10),
                          Text(
                            contactNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.location_on,
                      label: 'Shop Address',
                      value: shopAddress,
                      iconColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
