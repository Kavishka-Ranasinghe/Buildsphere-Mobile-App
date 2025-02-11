import 'dart:ui';
import 'package:flutter/material.dart';
import 'Signup Pages/other_sign_up.dart'; // Import SignUpPage for navigation
import 'room_section.dart'; // Import HomePage for navigation
import 'Hardware Shop Owner/hso_home.dart'; // HardwareShopOwnerPage

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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

          // Buildup Ceylon Text
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Buildup Ceylon",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow.shade600, // Yellow font color
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                      _buildInputField("Email"),
                      const SizedBox(height: 15),

                      // Password Input
                      _buildInputField("Password", isPassword: true),
                      const SizedBox(height: 20),

                      // Login Button
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to HomePage on successful login
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const room_section()),
                            //room_section() -- customer and others home
                            //HardwareShopOwnerPage() -- hardware shop owner home
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 10),

                      // Forgot Password
                      TextButton(
                        onPressed: () {
                          // Handle forgot password
                        },
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
                            MaterialPageRoute(builder: (context) => const SignUpPage()),
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

  // Input Field Widget
  Widget _buildInputField(String label, {bool isPassword = false}) {
    return TextField(
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
    );
  }
}
