import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? selectedFilter = "All"; // Default to "All"
  // Fetch user details
  @override
  void initState() {
    super.initState();
    _fetchUserDistrictCity();
  }

  Future<void> _fetchUserDistrictCity() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          selectedDistrict = userDoc['district'] ?? null;
          selectedCity = userDoc['city'] ?? null;
        });
      }
    }
  }

  // Placeholder data
  final List<String> districts = [
    'Colombo', 'Gampaha', 'Kalutara', 'Kandy', 'Matale', 'Nuwara Eliya',
    'Galle', 'Matara', 'Hambantota', 'Jaffna', 'Kilinochchi', 'Mannar', 'Vavuniya',
    'Mullaitivu', 'Batticaloa', 'Ampara', 'Trincomalee', 'Kurunegala', 'Puttalam',
    'Anuradhapura', 'Polonnaruwa', 'Badulla', 'Monaragala', 'Ratnapura', 'Kegalle'
  ];
  final Map<String, List<String>> cities = {
    'Colombo': ['Colombo 1', 'Colombo 2', 'Colombo 3', 'Nugegoda', 'Dehiwala', 'Maharagama', 'Piliyandala', 'Homagama', 'Kottawa', 'Battaramulla', 'Koswatta'],
    'Gampaha': ['Negombo', 'Gampaha', 'Ja-Ela', 'Wattala', 'Minuwangoda', 'Kelaniya', 'Ragama', 'Mirigama', 'Katunayake', 'Ganemulla'],
    'Kalutara': ['Kalutara', 'Panadura', 'Horana', 'Beruwala', 'Matugama', 'Aluthgama', 'Wadduwa', 'Ingiriya', 'Payagala', 'Bandaragama'],
    'Kandy': ['Kandy', 'Peradeniya', 'Katugastota', 'Gampola', 'Nawalapitiya', 'Wattegama', 'Digana', 'Pilimathalawa', 'Teldeniya', 'Kadugannawa'],
    'Matale': ['Matale', 'Dambulla', 'Galewela', 'Rattota', 'Ukuwela', 'Palapathwala', 'Laggala', 'Nalanda'],
    'Nuwara Eliya': ['Nuwara Eliya', 'Hatton', 'Ginigathhena', 'Kotagala', 'Talawakelle', 'Ragala', 'Pundaluoya', 'Dayagama'],
    'Galle': ['Galle', 'Hikkaduwa', 'Unawatuna', 'Ambalangoda', 'Karapitiya', 'Weligama', 'Ahangama', 'Bentota', 'Koggala', 'Balapitiya'],
    'Matara': ['Matara', 'Weligama', 'Akurassa', 'Deniyaya', 'Hakmana', 'Dikwella', 'Kamburugamuwa', 'Devinuwara', 'Weeraketiya'],
    'Hambantota': ['Hambantota', 'Tangalle', 'Beliatta', 'Tissamaharama', 'Sooriyawewa', 'Weerawila', 'Lunugamvehera', 'Kirinda'],
    'Jaffna': ['Jaffna', 'Nallur', 'Point Pedro', 'Chavakachcheri', 'Kopay', 'Atchuvely', 'Karainagar', 'Kankesanthurai', 'Velanai'],
    'Kilinochchi': ['Kilinochchi', 'Pallai', 'Paranthan', 'Mallavi', 'Tharmapuram', 'Kandavalai'],
    'Mannar': ['Mannar', 'Murunkan', 'Pesalai', 'Thalaimannar', 'Madhu'],
    'Vavuniya': ['Vavuniya', 'Nedunkeni', 'Omanthai', 'Cheddikulam', 'Parayanalankulam'],
    'Mullaitivu': ['Mullaitivu', 'Puthukudiyiruppu', 'Oddusuddan', 'Maritimepattu', 'Thunukkai'],
    'Batticaloa': ['Batticaloa', 'Kaluwanchikudy', 'Eravur', 'Valachchenai', 'Kattankudy', 'Chenkalady', 'Vakarai'],
    'Ampara': ['Ampara', 'Kalmunai', 'Sainthamaruthu', 'Akkaraipattu', 'Sammanthurai', 'Dehiattakandiya', 'Uhana'],
    'Trincomalee': ['Trincomalee', 'Kinniya', 'Mutur', 'Nilaveli', 'Kantale', 'China Bay'],
    'Kurunegala': ['Kurunegala', 'Kuliyapitiya', 'Pannala', 'Mawathagama', 'Narammala', 'Alawwa', 'Polgahawela', 'Wariyapola', 'Nikaweratiya', 'Galgamuwa'],
    'Puttalam': ['Puttalam', 'Chilaw', 'Wennappuwa', 'Nattandiya', 'Marawila', 'Anamaduwa', 'Madampe'],
    'Anuradhapura': ['Anuradhapura', 'Kekirawa', 'Mihintale', 'Thambuttegama', 'Eppawala', 'Nochchiyagama'],
    'Polonnaruwa': ['Polonnaruwa', 'Hingurakgoda', 'Medirigiriya', 'Dimbulagala'],
    'Badulla': ['Badulla', 'Bandarawela', 'Haputale', 'Welimada', 'Mahiyanganaya', 'Diyatalawa', 'Passara'],
    'Monaragala': ['Monaragala', 'Wellawaya', 'Bibile', 'Medagama', 'Siyambalanduwa'],
    'Ratnapura': ['Ratnapura', 'Embilipitiya', 'Pelmadulla', 'Balangoda', 'Eheliyagoda', 'Kuruwita', 'Opanayaka'],
    'Kegalle': ['Kegalle', 'Mawanella', 'Warakapola', 'Ruwanwella', 'Dehiowita', 'Deraniyagala'],
  };


  final List<String> filters = ['All', 'Cement', 'Soil', 'Brick', 'Pebbles']; // Added "All"

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
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
              child: Container(
                color: Colors.black.withOpacity(0.2), // Dark overlay
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
                        'Raw Supply',
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
              // Centering the Dropdowns
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, // Solid White Background
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // District Dropdown
                          _buildDropdown(
                            hint: "Select District",
                            value: selectedDistrict,
                            items: districts,
                            onChanged: (value) {
                              setState(() {
                                selectedDistrict = value;
                                selectedCity = null; // Reset city when district changes
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          // City Dropdown (only shown when district is selected)
                          if (selectedDistrict != null)
                            _buildDropdown(
                              hint: "Select City",
                              value: selectedCity,
                              items: cities[selectedDistrict]!,
                              onChanged: (value) {
                                setState(() {
                                  selectedCity = value;
                                });
                              },
                            ),
                          const SizedBox(height: 10),
                          // Filter Dropdown with "All" Option
                          _buildDropdown(
                            hint: "Select Filter",
                            value: selectedFilter,
                            items: filters,
                            onChanged: (value) {
                              setState(() {
                                selectedFilter = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Item Listings
              if (selectedCity != null)
                Expanded(
                  child: ListView.builder(
                    itemCount: 5, // Placeholder for filtered posts
                    itemBuilder: (context, index) {
                      return _buildItemCard(
                        index: index,
                        itemType: selectedFilter == "All" ? "Various Items" : selectedFilter!,
                        onCall: () => _callNumber('0771234567'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RawItemDetailScreen(
                                itemName: 'Item $index',
                                itemType: selectedFilter == "All" ? "Various Items" : selectedFilter!,
                                price: 'Rs. 100/block',
                                shopName: 'ABC Hardware',
                                shopAddress: '123 Main Street, Colombo',
                                contactNumber: '0771234567',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required void Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
    );
  }
}
  Future<Widget> _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) async {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildItemCard({
    required int index,
    required String itemType,
    required VoidCallback onCall,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/item_placeholder.png'), // Placeholder image
          radius: 28,
        ),
        title: Text('Item $index', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item Type: $itemType'),
            const Text('Price: Rs. 100/block'),
            const Text('Shop: ABC Hardware'),
            const Text('Contact: 0771234567'),
          ],
        ),
        isThreeLine: true,
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: onCall,
        ),
      ),
    );
  }

