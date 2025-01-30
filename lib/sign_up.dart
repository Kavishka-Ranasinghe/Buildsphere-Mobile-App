import 'package:flutter/material.dart';
import 'login.dart'; // Import the LoginPage
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

    // If all fields are valid, show success message
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
      appBar: AppBar(
        title: const Text('Sign Up Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/sign-up.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name Input
              if (_nameError != null)
                Text(_nameError!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Role Selection
              if (_roleError != null)
                Text(_roleError!, style: const TextStyle(color: Colors.red)),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Email Input
              if (_emailError != null)
                Text(_emailError!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Password Input
              if (_passwordError != null)
                Text(_passwordError!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Confirm Password Input
              if (_confirmPasswordError != null)
                Text(_confirmPasswordError!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _confirmPasswordController,
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
              const SizedBox(height: 20),

              // Hardware Shop Owner Registration Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HardwareShopOwnerSignUpPage()),
                  );
                },
                child: const Text('Register as Hardware-Shop Owner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
