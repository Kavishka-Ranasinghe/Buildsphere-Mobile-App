import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? selectedCategory;
  DocumentSnapshot? selectedUser;
  int productCount = 0;
  bool loadingProducts = false;

  final List<String> userRoles = ['Client', 'Planner', 'Engineer', 'Hardware Shop Owner'];

  // Fetch users from Firestore based on role
  Stream<QuerySnapshot> getUsersByRole(String role) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots();
  }

  // Count products added by hardware shop owner
  Future<int> getProductCount(String ownerId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return querySnapshot.size;
  }

  // Delete user (and products if hardware shop owner)
  Future<void> deleteUserAndData(DocumentSnapshot userDoc) async {
    final userId = userDoc.id;
    final role = userDoc['role'];

    if (role == 'Hardware Shop Owner') {
      // Delete all products by owner
      final products = await FirebaseFirestore.instance
          .collection('products')
          .where('ownerId', isEqualTo: userId)
          .get();
      for (var product in products.docs) {
        await product.reference.delete();
      }
    }

    // Delete user document
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();

    setState(() {
      selectedUser = null;
      productCount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User and associated data deleted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text("Select User Role"),
              items: userRoles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  selectedUser = null;
                  productCount = 0;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            if (selectedCategory != null)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getUsersByRole(selectedCategory!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final users = snapshot.data!.docs;
                    if (users.isEmpty) return const Text("No users found for this role.");

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          title: Text(user['name'] ?? 'No Name'),
                          subtitle: Text(user['email'] ?? 'No Email'),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () async {
                            setState(() {
                              selectedUser = user;
                              productCount = 0;
                              loadingProducts = true;
                            });

                            if (user['role'] == 'Hardware Shop Owner') {
                              final count = await getProductCount(user.id);
                              setState(() {
                                productCount = count;
                                loadingProducts = false;
                              });
                            } else {
                              loadingProducts = false;
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),

            if (selectedUser != null)
              Card(
                margin: const EdgeInsets.only(top: 20),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User Details", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Text("Name: ${selectedUser!['name']}"),
                      Text("Email: ${selectedUser!['email']}"),
                      Text("Role: ${selectedUser!['role']}"),
                      if (selectedUser!.data().toString().contains('phone'))
                        Text("Phone: ${selectedUser!['phone']}"),
                      if (selectedUser!.data().toString().contains('address'))
                        Text("Address: ${selectedUser!['address']}"),
                      const SizedBox(height: 10),
                      if (selectedUser!['role'] == 'Hardware Shop Owner')
                        loadingProducts
                            ? const Text("Loading product count...")
                            : Text("Total Products: $productCount"),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => deleteUserAndData(selectedUser!),
                            icon: const Icon(Icons.delete_forever),
                            label: const Text("Delete User"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => setState(() => selectedUser = null),
                            icon: const Icon(Icons.cancel),
                            label: const Text("Cancel"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          ),
                        ],
                      )
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
