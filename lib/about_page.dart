import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      _showCongratulationsPopup(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About BuildSphere',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'BuildSphere Mobile Application - A Smart Communication and Material Sourcing App for the Construction Industry',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Supervisor Section
                        _buildTeamMember(
                          context: context,
                          name: 'Project Supervisor: \nProf. Chaminda Wijesinghe \n',
                          imagePath: 'assets/images/Dr.Chaminda-Wijesinghe.webp',
                          url: 'https://www.nsbm.ac.lk/staff/dr-chaminda-wijesinghe/',
                          text: null,
                        ),
                        const SizedBox(height: 20),
                        // Developer Section
                        _buildTeamMember(
                          context: context,
                          name: 'Developer:\n Kavishka Ranasinghe',
                          imagePath: 'assets/images/kavishka.jpg',
                          url: 'https://www.linkedin.com/in/kavishka-ranasinghe-5a8287242',
                          text: 'Plymouth Name -\nPulihinga M Ranasinghe \n'
                              'Student ID - 10898626 \n',
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 30),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About BuildSphere',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'BuildSphere is a mobile-first application developed to streamline communication and procurement in the Sri Lankan construction industry. It connects clients, engineers, planners, and hardware shop owners on a single real-time platform, while providing administrators with account management capabilities through a dedicated web dashboard.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.2, end: 0),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Features:',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '- Real-time communication between clients, engineers, and planners.\n'
                              '- AI-powered material scanning using Google Vision API.\n'
                              '- Direct contact with suppliers.\n'
                              '- Document sharing and project planning in Group chat.\n'
                              '- Admin panel to manage users.\n'
                              '- Hardware shop owners can list raw materials so Clients can browse, compare, and contact suppliers directly\n',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: 0.2, end: 0),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Created  for the NSBM / University of Plymouth final-year project under the supervision of Prof. Chaminda Wijesinghe',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 800.ms).scale(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember({
    required BuildContext context,
    required String name,
    required String imagePath,
    required String url,
    String? text,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageView(imagePath: imagePath),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: () => _launchUrl(url),
                child: Row(
                  children: [
                    const Icon(
                      Icons.link,
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        url,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (text != null) ...[
                const SizedBox(height: 10),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showCongratulationsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Congratulations!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'You found the hidden page!!!',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
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