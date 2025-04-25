import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app_drawer.dart';

class ShopDetailScreen extends StatelessWidget {
  final String ownerId; // 🔑 UID of the hardware shop owner

  const ShopDetailScreen({super.key, required this.ownerId});

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

  void _openGoogleMaps(BuildContext context, String url) async {
    final Uri mapsUri = Uri.parse(url);
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
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
            Navigator.pop(context); // 👈 Goes back to the previous screen
          },
        ),
      ),

      drawer: const AppDrawer(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(ownerId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final shopName = data['shopName'] ?? 'N/A';
          final address = data['address'] ?? 'N/A';
          final phone = data['phone'] ?? 'N/A';
          final mapLink = data['mapLink'] ?? '';
          final profileImage = data['profileImage'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ Shop Image
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: profileImage != null
                        ? CachedNetworkImage(
                      imageUrl: profileImage,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Image.asset('assets/images/h_shop.jpg'),
                    )
                        : Image.asset('assets/images/h_shop.jpg', height: 200),
                  ),
                ),
                const SizedBox(height: 20),

                // 🏪 Shop Info
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shop Name: $shopName',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Address: $address', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _callNumber(context, phone),
                          child: Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.green, size: 28),
                              const SizedBox(width: 10),
                              Text(
                                phone,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
                ),

                const SizedBox(height: 20),

                // 🗺️ Google Maps Section
                GestureDetector(
                  onTap: mapLink.isNotEmpty ? () => _openGoogleMaps(context, mapLink) : null,
                  child: Row(
                    children: [
                      const Icon(Icons.location_pin, color: Colors.red, size: 30),
                      const SizedBox(width: 8),
                      mapLink.isNotEmpty
                          ? const Text(
                        'View on Google Maps',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      )
                          : const Text(
                        'No location added',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
