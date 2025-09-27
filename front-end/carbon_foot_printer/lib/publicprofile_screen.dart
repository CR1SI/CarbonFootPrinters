import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_screen.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fb_auth.User? currentUser = fb_auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    // StreamBuilder fetches Firestore data in real-time
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final username = userData['name'] ?? 'Unknown';
        final pfpIndex = userData['pfp'] ?? 0;

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
      },
    );
  }
}
