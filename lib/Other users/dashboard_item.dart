import 'package:flutter/material.dart';

class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap; // New callback for handling taps

  const DashboardItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap, // Initialize the onTap callback
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Makes the entire item clickable
      onTap: onTap, // Handles the tap action
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16), // Adjust padding for better layout
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
