import 'package:flutter/material.dart';
import 'settings_screen.dart';

class PublicProfileScreen extends StatelessWidget {
  final String username;
  final int pfpIndex;

  const PublicProfileScreen({
    super.key,
    required this.username,
    required this.pfpIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              CircleAvatar(
                radius: 50,
                backgroundColor:
                    Colors.primaries[pfpIndex % Colors.primaries.length],
                child: const Icon(Icons.person,
                    size: 50, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                username.toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 10, 79, 54),
                ),
              ),
              Text("@${username.toLowerCase()}"),
              const SizedBox(height: 20),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text("Carbon Emissions this week (graph here)"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}