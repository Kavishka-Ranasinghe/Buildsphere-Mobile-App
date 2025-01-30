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

  final _formKey = GlobalKey<FormState>();

  // Error messages
  String? _shopNameError;
  String? _shopEmailError;
  String? _shopAddressError;
  String? _shopPhoneError;
  String? _shopPasswordError;
  String? _shopConfirmPasswordError;

  void _showSignUpSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Sign-up successful! You can now log in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ); // Navigate to LoginPage
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _validateEmail(String email) {
    final RegExp emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _validateInputs() {
    setState(() {
      _shopNameError = _shopNameController.text.isEmpty ? 'Shop Name is required' : null;
      _shopEmailError = _shopemailController.text.isEmpty
          ? 'Email is required'
          : (!_validateEmail(_shopemailController.text) ? 'Enter a valid email' : null);
      _shopAddressError = _shopAddressController.text.isEmpty ? 'Shop Address is required' : null;
      _shopPhoneError = _shopPhoneController.text.isEmpty ? 'Telephone Number is required' : null;
      _shopPasswordError = _shoppasswordController.text.length < 6
          ? 'Password must be at least 6 characters'
          : null;
      _shopConfirmPasswordError = _shopconfirmPasswordController.text != _shoppasswordController.text
          ? 'Passwords do not match'
          : null;
    });

    // If all fields are valid, show success message
    if (_shopNameError == null &&
        _shopEmailError == null &&
        _shopAddressError == null &&
        _shopPhoneError == null &&
        _shopPasswordError == null &&
        _shopConfirmPasswordError == null) {
      _showSignUpSuccessDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hardware Shop Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Shop Name Input
              if (_shopNameError != null)
                Text(_shopNameError!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Email Input
              if (_shopEmailError != null)
                Text(_shopEmailError!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _shopemailController,
                decoration: const InputDecoration(
                  labelText: 'Shop Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Shop Address Input
              if (_shopAddressError != null)
                Text(_shopAddressError!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _shopAddressController,
                decoration: const InputDecoration(
                  labelText: 'Shop Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number Input
              if (_shopPhoneError != null)
                Text(_shopPhoneError!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _shopPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Telephone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Password Input
              if (_shopPasswordError != null)
                Text(_shopPasswordError!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _shoppasswordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Confirm Password Input
              if (_shopConfirmPasswordError != null)
                Text(_shopConfirmPasswordError!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _shopconfirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Sign Up Button
              ElevatedButton(
                onPressed: _validateInputs,
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 20),

              // Back to Normal Sign Up
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Other User Sign Up Page'),
              ),
              const SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                onPressed: () {
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
      ),
    );
  }
}
