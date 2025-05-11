import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      _showCongratulationsPopup(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('About BuildSphere'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'BuildSphere Mobile Application - A Smart Communication and Material Sourcing App for the Construction Industry',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const SizedBox(height: 30),
              // Supervisor Section
              const Text(
                'Supervisor: Prof. Chaminda Wijesinghe',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageView(
                        imagePath: 'assets/images/Dr.Chaminda-Wijesinghe.webp',
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/Dr.Chaminda-Wijesinghe.webp',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _launchUrl('https://www.nsbm.ac.lk/staff/dr-chaminda-wijesinghe/'),
                child: const Text(
                  'https://www.nsbm.ac.lk/staff/dr-chaminda-wijesinghe/',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Developer Section
              const Text(
                'Developer: Kavishka Ranasinghe',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageView(
                        imagePath: 'assets/images/kavishka.jpg',
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/kavishka.jpg',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _launchUrl('https://www.linkedin.com/in/kavishka-ranasinghe-5a8287242'),
                child: const Text(
                  'www.linkedin.com/in/kavishka-ranasinghe-5a8287242',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(
                'About BuildSphere',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'BuildSphere is a mobile-first application developed to streamline communication and procurement in the Sri Lankan construction industry. It connects clients, engineers, planners, and hardware shop owners on a single real-time platform, while providing administrators with account management capabilities through a dedicated web dashboard.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Key Features:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '- Real-time communication between clients, engineers, and planners.\n'
                    '- AI-powered material scanning using Google Vision API.\n'
                    '- Direct contact with  suppliers.\n'
                    '- Document sharing and project planning in Group chat.\n'
                    '- Admin panel to manage users.\n'
                    '- Hardware shop owners can list raw materials so Clients can browse, compare, and contact suppliers directly\n',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Created with for the NSBM / University of Plymouth final-year project under the supervision of Prof. Chaminda Wijesinghe\n',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imagePath;

  const FullScreenImageView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.asset(imagePath),
        ),
      ),
    );
  }
}