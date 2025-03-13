import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Show the popup message when the page opens
    Future.delayed(Duration.zero, () {
      _showCongratulationsPopup(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('About BuildSphere'),
        backgroundColor: Colors.green,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About BuildSphere',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'BuildSphere is a revolutionary platform designed to streamline communication, material sourcing, and project management within the construction industry in Sri Lanka. '
                  'The app connects planners, engineers, customers, and suppliers in real time, ensuring efficiency and transparency in every project.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Key Features:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '- Real-time communication between clients, engineers, and planners.\n'
                  '- AI-powered material scanning using Google Vision API.\n'
                  '- Direct contact with verified suppliers.\n'
                  '- Document sharing and project planning tools.\n'
                  '- Sustainable and smart construction recommendations.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'BuildSphere - Transforming Construction with Technology!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show popup message
  void _showCongratulationsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(' Congratulations! '),
          content: const Text('You found the hidden page!!!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
