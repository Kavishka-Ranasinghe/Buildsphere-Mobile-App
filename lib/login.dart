import 'dart:ui';
import 'package:flutter/material.dart';
import 'Signup Pages/other_sign_up.dart'; // SignUpPage for navigation
import 'Other users/room_section.dart'; // HomePage for normal users
import 'Hardware Shop Owner/hso_home.dart'; // HardwareShopOwnerPage
import 'Admin/admin_dash.dart'; // Admin Dashboard
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart'as comet_chat;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cometchat_sdk/cometchat_sdk.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true; // Toggle password visibility

  // Admin Credentials
  final String adminEmail = "Buildsphere@gmail.com";
  final String adminPassword = "password";



  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    // Check if entered credentials match admin credentials
    if (email == adminEmail && password == adminPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful")),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
      );
      return;
    }

    try {
      firebase_auth.UserCredential userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      firebase_auth.User? user = userCredential.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful")),
        );
        await Future.delayed(const Duration(seconds: 1));

        // Fetch user role from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String userRole = userDoc['role'];

          if (userRole == 'Client' || userRole == 'Engineer' || userRole == 'Planner') {
            // ✅ Authenticate User with CometChat after Firebase Login
            await cometChatLogin();

            // ✅ Navigate to Room Section after successful login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const room_section()),
            );
          } else if (userRole == 'Hardware Shop Owner') {
            // ❌ Hardware Shop Owners do not belong to CometChat → Skip CometChat login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HardwareShopOwnerPage()),
            );
          } else {
            // Handle other roles if needed or show an error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Unknown user role")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not found.")),
          );
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    }
  }
  Future<void> cometChatLogin() async {
    String authKey = "6d0dad629d71caa8a4f436f2920daa048feaaa8e"; // Your CometChat Auth Key

    // ✅ Get Firebase user details
    firebase_auth.User? firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      print("❌ Firebase user is null!");
      return;
    }

    String uid = firebaseUser.uid;
    String name = firebaseUser.displayName ?? "Anonymous User";

    // ✅ Create CometChat User (if not exists)
    User user = User(
      uid: uid,
      name: name,
    );

    await CometChat.createUser(user, authKey,
        onSuccess: (User createdUser) {
          print("✅ CometChat user created successfully: ${createdUser.uid}");
        },
        onError: (CometChatException e) {
          print("⚠️ CometChat user already exists or error: ${e.message}");
        });

    // ✅ Login User into CometChat
    await CometChat.login(uid, authKey,
        onSuccess: (User loggedInUser) {
          print("✅ CometChat login successful: ${loggedInUser.uid}");
        },
        onError: (CometChatException e) {
          print("❌ CometChat login failed: ${e.message}");
        });
  }



  // Forgot Password Function
  void _forgotPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email to reset password")),
      );
      return;
    }

    try {
      await firebase_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset link sent to your email")),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Failed to send reset email")),
      );
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
                color: Colors.black.withOpacity(0.5), // Adds a subtle dark overlay
              ),
            ),
          ),

          // Buildsphere Text (Hides when keyboard is open)
          if (!isKeyboardOpen)
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Buildsphere",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow.shade600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

          // Login Form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.6)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Login Page",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Input
                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.8)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Password Input with Show Password Button
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.8)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 10),

                      // Forgot Password
                      TextButton(
                        onPressed: _forgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      // Sign Up Navigation
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
