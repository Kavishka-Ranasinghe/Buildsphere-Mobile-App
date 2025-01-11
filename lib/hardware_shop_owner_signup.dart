import 'package:flutter/material.dart';


class HardwareShopOwnerSignUpPage extends StatefulWidget {
  const HardwareShopOwnerSignUpPage({super.key});

  @override
  _HardwareShopOwnerSignUpPageState createState() => _HardwareShopOwnerSignUpPageState();
}

class _HardwareShopOwnerSignUpPageState extends State<HardwareShopOwnerSignUpPage> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopPhoneController = TextEditingController();
  final TextEditingController _shopLocationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hardware Shop Owner Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sign-up.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _shopNameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _shopAddressController,
              decoration: const InputDecoration(
                labelText: 'Shop Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _shopPhoneController,
              decoration: const InputDecoration(
                labelText: 'Telephone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _shopLocationController,
              decoration: const InputDecoration(
                labelText: 'Location (Town)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle hardware shop owner registration logic here
              },
              child: const Text('Sign up'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back to normal sign-up page
                Navigator.pop(context);
              },
              child: const Text('Back to Other Sign Up Page'),
            ),
          ],
        ),
      ),
    );
  }
}
