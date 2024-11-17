import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile.dart';
import 'app_drawer.dart';

class ItemShoppingScreen extends StatelessWidget {
  const ItemShoppingScreen({super.key});

  // Function to search for an item
  void _searchItem(String query, BuildContext context) async {
    final url =
        'https://www.daraz.lk/catalog/?spm=a2a0e.tm80335410.search.d_go&q=${Uri.encodeComponent(query)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

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
                        'Item Shopping',
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
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search for an item',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (query) => _searchItem(query, context),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text("Search"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.yellowAccent,
                        ),
                        onPressed: () => _searchItem(searchController.text, context),
                      ),
                    ),
                    const SizedBox(width: 50),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Scan Item"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.yellowAccent,
                      ),
                      onPressed: () {
                        // Placeholder for Google Vision API functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Opening camera to scan item...")),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Placeholder for search results
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      'I',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('Item $index'),
                  subtitle: const Text('Description of the item...'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Opening details for Item $index")),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
