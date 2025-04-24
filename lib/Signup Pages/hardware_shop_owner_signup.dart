import 'dart:ui';
import 'package:flutter/material.dart';
import '../login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Hardware Shop Owner/hso_home.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../no_internet_screen.dart'; // ⬅️ Make sure this exists

class HardwareShopOwnerSignUpPage extends StatefulWidget {
  const HardwareShopOwnerSignUpPage({super.key});

  @override
  _HardwareShopOwnerSignUpPageState createState() => _HardwareShopOwnerSignUpPageState();
}

class _HardwareShopOwnerSignUpPageState extends State<HardwareShopOwnerSignUpPage> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopEmailController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopPhoneController = TextEditingController();
  final TextEditingController _shopPasswordController = TextEditingController();
  final TextEditingController _shopConfirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _shopNameError;
  String? _shopEmailError;
  String? _shopAddressError;
  String? _shopPhoneError;
  String? _shopPasswordError;
  String? _shopConfirmPasswordError;

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
          content: const Text('Sign-up successful! You will be redirected to seller home page.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HardwareShopOwnerPage()),
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
          content: const Text('Wait for approval, Give us few seconds please.'),
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
    final RegExp emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _signUpWithFirebase() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _shopEmailController.text.trim(),
        password: _shopPasswordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'shopName': _shopNameController.text.trim(),
          'email': _shopEmailController.text.trim(),
          'address': _shopAddressController.text.trim(),
          'phone': _shopPhoneController.text.trim(),
          'role': 'Hardware Shop Owner',
          'createdAt': Timestamp.now(),
        });

        await user.updateDisplayName(_shopNameController.text.trim());
        await user.reload();

        _waitapproval();
        _showSignUpSuccessDialog();

      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _shopEmailError = 'Email is already in use';
        } else if (e.code == 'weak-password') {
          _shopPasswordError = 'Weak password';
        } else {
          _shopEmailError = 'Sign-up failed: ${e.message}';
        }
      });
    }
  }

  void _validateInputs() {
    setState(() {
      _shopNameError = _shopNameController.text.isEmpty ? 'Shop Name is required' : null;
      _shopEmailError = _shopEmailController.text.isEmpty
          ? 'Email is required'
          : (!_validateEmail(_shopEmailController.text) ? 'Enter a valid email' : null);
      _shopAddressError = _shopAddressController.text.isEmpty ? 'Shop Address is required' : null;
      _shopPhoneError = _shopPhoneController.text.isEmpty ? 'Telephone Number is required' : null;
      _shopPasswordError = _shopPasswordController.text.length < 6
          ? 'Password must be at least 6 characters' : null;
      _shopConfirmPasswordError = _shopConfirmPasswordController.text != _shopPasswordController.text
          ? 'Passwords do not match' : null;
    });

    if (_shopNameError == null &&
        _shopEmailError == null &&
        _shopAddressError == null &&
        _shopPhoneError == null &&
        _shopPasswordError == null &&
        _shopConfirmPasswordError == null) {
      _signUpWithFirebase();
      _waitapproval();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return const NoInternetScreen(); // ⬅️ Show when offline
    }

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
                          "Hardware Shop Registration",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        _buildInputField("Shop Name", _shopNameController, _shopNameError),
                        const SizedBox(height: 15),
                        _buildInputField("Shop Email", _shopEmailController, _shopEmailError),
                        const SizedBox(height: 15),
                        _buildInputField("Shop Address", _shopAddressController, _shopAddressError),
                        const SizedBox(height: 15),
                        _buildInputField("Telephone Number", _shopPhoneController, _shopPhoneError,
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 15),
                        _buildInputField("Password", _shopPasswordController, _shopPasswordError, isPassword: false),
                        const SizedBox(height: 15),
                        _buildInputField("Confirm Password", _shopConfirmPasswordController, _shopConfirmPasswordError, isPassword: false),
                        const SizedBox(height: 20),
                        _buildButton("Sign Up", _validateInputs),
                        const SizedBox(height: 15),
                        _buildButton("Back to Other User Sign Up Page", () => Navigator.pop(context)),
                        const SizedBox(height: 15),
                        _buildButton("Login Page", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
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

  Widget _buildInputField(String label, TextEditingController controller, String? error,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != null)
          Text(error, style: const TextStyle(color: Colors.red)),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
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
