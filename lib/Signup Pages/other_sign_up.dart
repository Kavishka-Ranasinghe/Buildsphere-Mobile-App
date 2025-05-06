import 'dart:ui';
import 'package:flutter/material.dart';
import '../login.dart';
import 'hardware_shop_owner_signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Other users/room_section.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' as comet_chat;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../no_internet_screen.dart';

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

  String? _nameError;
  String? _roleError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

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
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const room_section()),
                );
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
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _validateEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> cometChatLogin(firebase_auth.User? firebaseUser) async {
    String authKey = "6d0dad629d71caa8a4f436f2920daa048feaaa8e";

    if (firebaseUser == null) return;

    String uid = firebaseUser.uid;
    String name = _nameController.text.trim();  // 🔥 get name directly from textbox

    comet_chat.User user = comet_chat.User(uid: uid, name: name);

    await CometChat.createUser(user, authKey,
        onSuccess: (comet_chat.User createdUser) {
          print("✅ CometChat user created successfully: ${createdUser.uid}");
        },
        onError: (CometChatException e) {
          print("⚠️ CometChat user may already exist or error: ${e.message}");
        });

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
      firebase_auth.UserCredential userCredential = await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      firebase_auth.User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole,
          'createdAt': Timestamp.now(),
        });

        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();
        await Future.delayed(const Duration(seconds: 4));
        firebase_auth.User? updatedUser = firebase_auth.FirebaseAuth.instance.currentUser; // 🔥 re-fetch updated user

        if (_selectedRole == 'Client' || _selectedRole == 'Engineer' || _selectedRole == 'Planner') {
          await cometChatLogin(updatedUser);
          _showSignUpSuccessDialog();
        } else {
          _waitapproval();
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
    if (!_isConnected) {
      return const NoInternetScreen();
    }

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/sign-up.jpeg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          if (!isKeyboardOpen)
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Buildsphere",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow.shade600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
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
                        const Text("Sign Up",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            )),
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
                        _buildInputField("Password", _passwordController, _passwordError, isPassword: false),
                        const SizedBox(height: 15),
                        _buildInputField("Confirm Password", _confirmPasswordController, _confirmPasswordError, isPassword: false),
                        const SizedBox(height: 20),
                        _buildButton("Sign Up", _validateInputs),
                        const SizedBox(height: 15),
                        _buildButton("Login Page", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                        }),
                        const SizedBox(height: 15),
                        _buildButton("Register as Hardware-Shop Owner", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HardwareShopOwnerSignUpPage()));
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
