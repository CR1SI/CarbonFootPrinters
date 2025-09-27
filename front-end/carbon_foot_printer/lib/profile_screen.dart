import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      body: Center(
        child: Container(
          width: 1000,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,   
        ),
        ),
      ),
    );
  }
}