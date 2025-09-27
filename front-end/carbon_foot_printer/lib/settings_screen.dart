import 'package:flutter/material.dart';
import 'login.dart';
import 'firebase_service.dart';

final AuthService _authService = AuthService();

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Varela',
            fontSize: 48,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // logout button color
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            await _authService.signOut(); // call your Firebase logout
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false, // removes all previous routes
              );
            }
          },
          child: const Text(
            'Logout',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
