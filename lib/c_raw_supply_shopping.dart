import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile.dart';
import 'app_drawer.dart';
import 'c_raw_item_detail.dart';

class RawSupplyScreen extends StatefulWidget {
  const RawSupplyScreen({super.key});

  @override
  _RawSupplyScreenState createState() => _RawSupplyScreenState();
}

class _RawSupplyScreenState extends State<RawSupplyScreen> {
  String? selectedDistrict;
  String? selectedCity;

  // Placeholder data
  final List<String> districts = ['Colombo', 'Kandy', 'Galle', 'Jaffna'];
  final Map<String, List<String>> cities = {
    'Colombo': ['Colombo 1', 'Colombo 2', 'Colombo 3'],
    'Kandy': ['Peradeniya', 'Katugastota', 'Gampola'],
    'Galle': ['Hikkaduwa', 'Unawatuna', 'Weligama'],
    'Jaffna': ['Nallur', 'Vaddukoddai', 'Point Pedro'],
  };

  // Function to redirect to the phone app
  void _callNumber(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buildup Ceylon',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raw Supply',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellowAccent,
                        ),
                      ),
                    ],
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: selectedDistrict,
                  hint: const Text("Select District"),
                  isExpanded: true,
                  items: districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                      selectedCity = null; // Reset city when district changes
                    });
                  },
                ),
                const SizedBox(height: 10),
                if (selectedDistrict != null)
                  DropdownButton<String>(
                    value: selectedCity,
                    hint: const Text("Select City"),
                    isExpanded: true,
                    items: cities[selectedDistrict]!.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value;
                      });
                    },
                  ),
              ],
            ),
          ),
          if (selectedCity != null)
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Placeholder for posts
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/item_placeholder.png'), // Placeholder image
                        radius: 28,
                      ),
                      title: Text('Item $index'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Item Type: Cement Blocks'),
                          const Text('Price: Rs. 100/block'),

                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RawItemDetailScreen(
                              itemName: 'Item $index',
                              itemType: 'Cement Blocks',
                              price: 'Rs. 100/block',
                              shopName: 'ABC Hardware',
                              shopAddress: '123 Main Street, Colombo',
                              contactNumber: '0771234567',
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _callNumber('0771234567'),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
