import 'package:flutter/material.dart';
import 'login.dart'; // Import the LoginPage


class HardwareShopOwnerSignUpPage extends StatefulWidget {
  const HardwareShopOwnerSignUpPage({super.key});

  @override
  _HardwareShopOwnerSignUpPageState createState() => _HardwareShopOwnerSignUpPageState();
}

class _HardwareShopOwnerSignUpPageState extends State<HardwareShopOwnerSignUpPage> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopemailController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopPhoneController = TextEditingController();
  final TextEditingController _shoppasswordController = TextEditingController();
  final TextEditingController _shopconfirmPasswordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hardware Shop Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

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
              controller: _shopemailController,
              decoration: const InputDecoration(
                labelText: ' Shop Email',
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
              controller: _shoppasswordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _shopconfirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
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
              child: const Text('Back to Other User Sign Up Page'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to LoginPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Login Page'),
            ),
          ],
        ),
      ),
    );
  }
}
