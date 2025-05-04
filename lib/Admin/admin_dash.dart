import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Example users data
  final Map<String, List<Map<String, dynamic>>> usersData = {
    'Client': [
      {'id': '1', 'name': 'John Doe', 'email': 'john@example.com'},
      {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com'},
    ],
    'Planner': [
      {'id': '3', 'name': 'Michael Johnson', 'email': 'michael@example.com'},
    ],
    'Engineer': [
      {'id': '4', 'name': 'Emma Brown', 'email': 'emma@example.com'},
    ],
    'Hardware Shop Owner': [
      {'id': '5', 'name': 'David Wilson', 'email': 'david@example.com'},
    ],
  };

  String? selectedCategory;
  Map<String, dynamic>? selectedUser;

  // Function to remove a user
  void _removeUser(String category, String userId) {
    setState(() {
      usersData[category]?.removeWhere((user) => user['id'] == userId);
      selectedUser = null; // Reset selected user after removal
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User removed successfully!')),
    );
  }

  // Function to cancel user selection
  void _cancelSelection() {
    setState(() {
      selectedUser = null; // Deselect the user
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select user category
            const Text("Select User Type"),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              items: usersData.keys.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  selectedUser = null; // Reset selected user when category changes
                });
              },
            ),
            const SizedBox(height: 20),

            // Display users based on selected category
            if (selectedCategory != null)
              Expanded(
                child: ListView(
                  children: usersData[selectedCategory]!.map((user) {
                    return ListTile(
                      title: Text(user['name']),
                      subtitle: Text(user['email']),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        setState(() {
                          selectedUser = user;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

            // Show selected user details
            if (selectedUser != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("User Details", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Text("Name: ${selectedUser!['name']}"),
                        Text("Email: ${selectedUser!['email']}"),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Remove User Button
                            ElevatedButton(
                              onPressed: () {
                                _removeUser(selectedCategory!, selectedUser!['id']);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text("Remove User"),
                            ),

                            // Cancel Button
                            ElevatedButton(
                              onPressed: _cancelSelection,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                              child: const Text("Cancel"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
