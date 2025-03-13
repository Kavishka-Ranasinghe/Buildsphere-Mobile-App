import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Other users/profile.dart';
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
  String? selectedFilter;

  // Placeholder data
  final List<String> districts = ['Colombo', 'Kandy', 'Galle', 'Jaffna'];
  final Map<String, List<String>> cities = {
    'Colombo': ['Colombo 1', 'Colombo 2', 'Colombo 3'],
    'Kandy': ['Peradeniya', 'Katugastota', 'Gampola'],
    'Galle': ['Hikkaduwa', 'Unawatuna', 'Weligama'],
    'Jaffna': ['Nallur', 'Vaddukoddai', 'Point Pedro'],
  };

  final List<String> filters = ['Cement', 'Soil', 'Brick', 'Pebbles'];

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
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedFilter,
                  hint: const Text("Select Filter"),
                  isExpanded: true,
                  items: filters.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value;
                    });
                  },
                ),
              ],
            ),
          ),
          if (selectedCity != null && selectedFilter != null)
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Placeholder for filtered posts
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
                          Text('Item Type: $selectedFilter'),
                          const Text('Price: Rs. 100/block'),
                          const Text('Shop: ABC Hardware'),
                          const Text('Contact: 0771234567'),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RawItemDetailScreen(
                              itemName: 'Item $index',
                              itemType: selectedFilter!,
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
