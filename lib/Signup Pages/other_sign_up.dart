import 'dart:ui';
import 'package:flutter/material.dart';
import '../login.dart'; // Import the LoginPage
import 'hardware_shop_owner_signup.dart'; // Import the HardwareShopOwnerSignUpPage
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Other users/room_section.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart'as comet_chat;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cometchat_sdk/cometchat_sdk.dart';



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
          title: const Text('Yeah!!! 🎉'),
          content: const Text('Sign-up successful! You will be redirected to the home page.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const room_section()),
                ); // Navigate to Chat Section
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _waitapproval() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Waiting'),
          content: const Text('Wait for approval, Give us few Seconds please.'),
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

  Future<void> cometChatLogin() async {
    String authKey = "406963557ec3469a8334514e054f7035ccee829b"; // Your CometChat Auth Key

    // ✅ Get Firebase user details
    firebase_auth.User? firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      print("❌ Firebase user is null!");
      return;
    }

    String uid = firebaseUser.uid;
    String name = firebaseUser.displayName ?? "Anonymous User";

    // ✅ Create CometChat User (if not exists)
    comet_chat.User user = comet_chat.User(
      uid: uid,
      name: name,
    );

    await CometChat.createUser(user, authKey,
        onSuccess: (comet_chat.User createdUser) {
          print("✅ CometChat user created successfully: ${createdUser.uid}");
        },
        onError: (CometChatException e) {
          print("⚠️ CometChat user already exists or error: ${e.message}");
        });

    // ✅ Login User into CometChat
    await CometChat.login(uid, authKey,
        onSuccess: (comet_chat.User loggedInUser) {
          print("✅ CometChat login successful: ${loggedInUser.uid}");
        },
        onError: (CometChatException e) {
          print("❌ CometChat login failed: ${e.message}");
        });
  }




  Future<void> _signUpWithFirebase() async {
    try {
      // Create user in Firebase Authentication
      firebase_auth.UserCredential userCredential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      firebase_auth.User? user = userCredential.user;

      if (user != null) {
        // Save user details in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole,
          'createdAt': Timestamp.now(),
        });

        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();

        // ✅ Check if user role is Client, Engineer, or Planner → then authenticate with CometChat
        if (_selectedRole == 'Client' || _selectedRole == 'Engineer' || _selectedRole == 'Planner') {
          await cometChatLogin();
          _showSignUpSuccessDialog(); // Navigates to `room_section`
        } else {
          _waitapproval(); // Navigates to `LoginPage` (for Hardware Shop Owners)
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _emailError = 'Email is already in use';
        } else if (e.code == 'weak-password') {
          _passwordError = 'Weak password';
        } else {
          _emailError = 'Sign-up failed: ${e.message}';
        }
      });
    }
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
      _signUpWithFirebase();
      _waitapproval();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
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

          // "Buildsphere" text
          if (!isKeyboardOpen)
          Positioned(
            top:30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Buildsphere",
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
                  padding: const EdgeInsets.all(10),
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
          obscureText: false,
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
