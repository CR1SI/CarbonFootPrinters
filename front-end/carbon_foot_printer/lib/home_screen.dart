import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome, USER',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Varela',
            fontSize: 48,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      ),
    );
  }
}