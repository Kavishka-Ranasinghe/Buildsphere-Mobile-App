import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile.dart';
import '../app_drawer.dart';
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
  bool _showFilters = true;
  String? Description;

  // Fetch user details
  @override
  void initState() {
    super.initState();
    _fetchUserDistrictCity();
  }
  Stream<QuerySnapshot> getFilteredProducts() {
    final productsRef = FirebaseFirestore.instance.collection('products');

    if ((selectedDistrict == null || selectedDistrict == 'None' || selectedDistrict == 'Sri Lanka') &&
        (selectedCity == null || selectedCity == 'None') &&
        selectedFilter == 'All') {
      return productsRef.snapshots(); // Get all
    }


    Query query = productsRef;

    if (selectedDistrict != null && selectedDistrict != 'None') {
      query = query.where('district', isEqualTo: selectedDistrict);
    }

    if (selectedCity != null && selectedCity != 'None') {
      query = query.where('town', isEqualTo: selectedCity);
    }

    if (selectedFilter != null && selectedFilter != 'All') {
      query = query.where('category', isEqualTo: selectedFilter);
    }

    return query.snapshots();
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
    'Sri Lanka','Colombo', 'Gampaha', 'Kalutara', 'Kandy', 'Matale', 'Nuwara Eliya',
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

              // Item Listings
              if (true)
                Expanded(
                  child: Stack(
                    children: [
                      // 🔁 Scrollable product list WITHOUT padding
                      StreamBuilder<QuerySnapshot>(
                        stream: getFilteredProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return ListView(
                              padding: const EdgeInsets.only(bottom: 80),
                              children: [
                                if (_showFilters)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          _buildDropdown(
                                            hint: "Select District",
                                            value: selectedDistrict,
                                            items: districts,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedDistrict = value;
                                                selectedCity = null;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          if (selectedDistrict != null)
                                            _buildDropdown(
                                              hint: "Select City",
                                              value: selectedCity,
                                              items: cities[selectedDistrict!]!,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedCity = value;
                                                });
                                              },
                                            ),
                                          const SizedBox(height: 10),
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
                                          const SizedBox(height: 10),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                selectedDistrict = null;
                                                selectedCity = null;
                                                selectedFilter = 'All';
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            ),
                                            icon: const Icon(Icons.refresh, color: Colors.white),
                                            label: const Text(
                                              'Reset Filters',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 60.0),
                                    child: Text(
                                      "No products found.",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );

                          }


                          final products = snapshot.data!.docs;

                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80), // enough for FAB
                            itemCount: (_showFilters ? 1 : 0) + products.length, // 👈 One extra item for filter box
                            itemBuilder: (context, index) {
                              if (_showFilters && index == 0) {
                                // 🔍 Return filter UI as first item in list
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        _buildDropdown(
                                          hint: "Select District",
                                          value: selectedDistrict,
                                          items: districts,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedDistrict = value;
                                              selectedCity = null;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        if (selectedDistrict != null)
                                          _buildDropdown(
                                            hint: "Select City",
                                            value: selectedCity,
                                            items: cities[selectedDistrict!]!,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedCity = value;
                                              });
                                            },
                                          ),
                                        const SizedBox(height: 10),
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
                                        const SizedBox(height: 10),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              selectedDistrict = null;
                                              selectedCity = null;
                                              selectedFilter = 'All';
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          ),
                                          icon: const Icon(Icons.refresh, color: Colors.white),
                                          label: const Text(
                                            'Reset Filters',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  ),
                                );
                              }

                              final actualIndex = _showFilters ? index - 1 : index;
                              final product = products[actualIndex].data() as Map<String, dynamic>;

                              return _buildItemCard(
                                product: product,
                                onCall: () => _callNumber(product['ownerTel'] ?? ''),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RawItemDetailScreen(
                                        imageUrl:product['imageUrl'] ??'N/A',
                                        itemName: product['name'] ?? 'N/A',
                                        itemType: product['category'] ?? 'N/A',
                                        price: product['price'] ?? 'N/A',
                                        shopName: product['shopName'] ?? 'N/A',
                                        shopAddress: product['address'] ?? 'N/A',
                                        contactNumber: product['ownerTel'] ?? '',
                                        description: product['description'] ?? 'N/A', // ✅ Add this line
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),




                      // 📎 Toggle Button
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton(
                          backgroundColor: Colors.green,
                          onPressed: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                          child: Icon(_showFilters ? Icons.close : Icons.filter_list),
                        ),
                      ),
                    ],
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
  required Map<String, dynamic> product,
  required VoidCallback onCall,
  required VoidCallback onTap,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 4,
    child: ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: product['imageUrl'] != null
            ? NetworkImage(product['imageUrl'])
            : const AssetImage('assets/images/item_placeholder.png') as ImageProvider,
      ),
      title: Text(
       "Name : ${product['name'] ?? 'N/A'}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Item Type: ${product['category'] ?? 'N/A'}"),
          Text("Price: LKR ${product['price'] ?? 'N/A'}"),
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


