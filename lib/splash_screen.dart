import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // Make sure this points to your main app entry
import 'sign_up.dart'; // Make sure this points to your main app entry


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // Function to check the login status and navigate accordingly
  _navigateToNextScreen() async {
    // Simulate a loading period for the splash screen
    await Future.delayed(const Duration(seconds: 5), () {});

    // Access SharedPreferences to check if the user is logged in
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('loggedIn') ?? false;

    // Navigate to the appropriate screen based on login status
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => loggedIn ? const MyHomePage(title: 'Flutter Demo Home Page') : const SignUpPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen height and width
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            color: Colors.green,  // Set your desired background color here
          ),
          // Full-screen image
          Positioned(
            top: screenHeight * 0.15,  // Positioning image based on screen height
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.7,  // Set height relative to screen height
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/splash01.png'),  // Replace with your image asset
                  fit: BoxFit.cover,  // Use cover to maintain aspect ratio
                ),
              ),
            ),
          ),
          // Centered "Welcome" text, positioned above the image with spacing
          Positioned(
            top: screenHeight * 0.10,  // Position based on screen height
            left: 0,
            right: 0,
            child: Text(
              'Welcome',  // Your welcome message
              style: TextStyle(
                color: Colors.yellow,  // Text color
                fontSize: screenWidth * 0.1,  // Text size relative to screen width
                fontWeight: FontWeight.bold,  // Text weight
                shadows: [
                  Shadow(
                    blurRadius: 10.0,  // Blur effect for better readability
                    color: Colors.black.withOpacity(0.10),  // Shadow color
                    offset: const Offset(2.0, 2.0),  // Offset for shadow
                  ),
                ],
              ),
              textAlign: TextAlign.center,  // Center the text
            ),
          ),
          // Centered app name text, positioned lower with spacing
          Positioned(
            bottom: screenHeight * 0.14,  // Position based on screen height
            left: 0,
            right: 0,
            child: Text(
              'Ceylon Buildup',  // Your app name
              style: TextStyle(
                color: Colors.yellow,  // Text color
                fontSize: screenWidth * 0.1,  // Text size relative to screen width
                fontWeight: FontWeight.bold,  // Text weight
                shadows: [
                  Shadow(
                    blurRadius: 10.0,  // Blur effect for better readability
                    color: Colors.black.withOpacity(0.10),  // Shadow color
                    offset: const Offset(2.0, 2.0),  // Offset for shadow
                  ),
                ],
              ),
              textAlign: TextAlign.center,  // Center the text
            ),
          ),
        ],
      ),
    );
  }
}
