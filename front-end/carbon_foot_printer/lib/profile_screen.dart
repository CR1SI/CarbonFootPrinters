import 'package:flutter/material.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

@override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 1000,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
                         children: [
                                      Align(
                 alignment: Alignment.topLeft,
      child: IconButton(
        icon: const Icon(Icons.share),
        color: const Color.fromARGB(255, 10, 79, 54),
        onPressed: () {
            },
              ),
          ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.settings),
                color: const Color.fromARGB(255, 10, 79, 54),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingScreen(),
                ),
              );
            },
              ),
          ),
        ],
          ),
          ),
          ),
        ],
      ),
    );
  }
}