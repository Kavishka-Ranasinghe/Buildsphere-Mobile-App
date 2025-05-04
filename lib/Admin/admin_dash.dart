import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? selectedCategory;
  final List<String> userRoles = ['Client', 'Planner', 'Engineer', 'Hardware Shop Owner'];

  // Fetch users by role
  Stream<QuerySnapshot> getUsersByRole(String role) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots();
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
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text("Select User Role"),
              items: userRoles
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedCategory = value);
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
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(user['name'] ?? 'No Name'),
                            subtitle: Text(user['email'] ?? 'No Email'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailsPage(userDoc: user),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ✅ New UserDetailsPage
class UserDetailsPage extends StatefulWidget {
  final DocumentSnapshot userDoc;

  const UserDetailsPage({super.key, required this.userDoc});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  int productCount = 0;
  bool loadingProducts = false;

  @override
  void initState() {
    super.initState();
    if (widget.userDoc['role'] == 'Hardware Shop Owner') {
      _fetchProductCount();
    }
  }

  Future<void> _fetchProductCount() async {
    setState(() => loadingProducts = true);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('ownerId', isEqualTo: widget.userDoc.id)
        .get();
    setState(() {
      productCount = querySnapshot.size;
      loadingProducts = false;
    });
  }

  Future<void> _disableUser() async {
    final userId = widget.userDoc.id;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'disabled': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User account disabled!')),
    );

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    final data = widget.userDoc.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  data['name'] ?? 'No Name',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Email: ${data['email']}"),
                Text("Role: ${data['role']}"),
                if (data.containsKey('phone')) Text("Phone: ${data['phone']}"),
                if (data.containsKey('address')) Text("Address: ${data['address']}"),
                if (widget.userDoc['role'] == 'Hardware Shop Owner')
                  loadingProducts
                      ? const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: CircularProgressIndicator(),
                  )
                      : Text("Total Products: $productCount"),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.block),
                  label: const Text("Disable User"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _disableUser,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
