import 'package:flutter/material.dart';
import 'user_home_screen.dart'; 

class ProfileScreen extends StatelessWidget {
  final String userEmail;

  const ProfileScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111D),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60), 
            
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151B2C),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFECC065), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFECC065).withOpacity(0.1), 
                          blurRadius: 10, 
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const Icon(Icons.person_rounded, size: 65, color: Color(0xFFECC065)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFECC065), shape: BoxShape.circle),
                    child: const Icon(Icons.star, size: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF151B2C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFECC065).withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildProfileItem(Icons.email_outlined, "Email Address", userEmail),
                    const Divider(color: Colors.white10, height: 24),
                    _buildProfileItem(Icons.security_outlined, "Account Status", "Verified Traveler"),
                    const Divider(color: Colors.white10, height: 24),
                    _buildProfileItem(Icons.location_on_outlined, "Region", "Teyvat (Mondstadt)"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('LOGOUT FROM TEYVAT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                onPressed: () {
                  globalToken = "";
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ),
            
            const SizedBox(height: 40),
            const Text(
              "Genshin Import v1.0.0",
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFECC065), size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}