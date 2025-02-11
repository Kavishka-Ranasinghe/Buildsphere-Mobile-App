import 'dart:ui';
import 'package:flutter/material.dart';
import '../login.dart'; // Import the LoginPage
import 'hardware_shop_owner_signup.dart'; // Import the HardwareShopOwnerSignUpPage

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedRole;
  final List<String> _roles = ['Client', 'Engineer', 'Planner'];

  final _formKey = GlobalKey<FormState>();

  // Error messages
  String? _nameError;
  String? _roleError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

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
      _nameError = _nameController.text.isEmpty ? 'Name is required' : null;
      _roleError = _selectedRole == null ? 'Please select a role' : null;
      _emailError = _emailController.text.isEmpty
          ? 'Email is required'
          : (!_validateEmail(_emailController.text) ? 'Enter a valid email' : null);
      _passwordError = _passwordController.text.length < 6
          ? 'Password must be at least 6 characters'
          : null;
      _confirmPasswordError = _confirmPasswordController.text != _passwordController.text
          ? 'Passwords do not match'
          : null;
    });

    if (_nameError == null &&
        _roleError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null) {
      _showSignUpSuccessDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/sign-up.jpeg', // Use the same background image
              fit: BoxFit.cover,
            ),
          ),

          // Blur effect overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2), // Adds a subtle dark overlay
              ),
            ),
          ),

          // "Buildup Ceylon" text
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Buildup Ceylon",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow.shade600, // Yellow font color
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // Signup form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildInputField("Name", _nameController, _nameError),
                        const SizedBox(height: 15),

                        _buildDropdownField("Select Role", _roles, _selectedRole, (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                        }, _roleError),
                        const SizedBox(height: 15),

                        _buildInputField("Email", _emailController, _emailError),
                        const SizedBox(height: 15),

                        _buildInputField("Password", _passwordController, _passwordError, isPassword: true),
                        const SizedBox(height: 15),

                        _buildInputField("Confirm Password", _confirmPasswordController, _confirmPasswordError, isPassword: true),
                        const SizedBox(height: 20),

                        _buildButton("Sign Up", _validateInputs),
                        const SizedBox(height: 15),

                        _buildButton("Login Page", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        }),
                        const SizedBox(height: 15),

                        _buildButton("Register as Hardware-Shop Owner", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HardwareShopOwnerSignUpPage()),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String? error, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != null)
          Text(error, style: const TextStyle(color: Colors.red)),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged, String? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != null)
          Text(error, style: const TextStyle(color: Colors.red)),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          dropdownColor: Colors.black.withOpacity(0.8),
        ),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.3),
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }
}
