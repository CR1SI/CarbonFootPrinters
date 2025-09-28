import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
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
    final fb_auth.User? currentUser = fb_auth.FirebaseAuth.instance.currentUser;

    // Optionally: if you want to override with Firestore data
    return StreamBuilder<DocumentSnapshot>(
      stream: currentUser != null
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .snapshots()
          : null,
      builder: (context, snapshot) {
        String displayName = username;
        int displayPfp = pfpIndex;

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          displayName = userData['name'] ?? username;
          displayPfp = userData['pfp'] ?? pfpIndex;
        }

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
                  // Top row: share + settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          // TODO: implement share
                        },
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

                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        Colors.primaries[displayPfp % Colors.primaries.length],
                    child: const Icon(Icons.person,
                        size: 50, color: Colors.white),
                  ),

                  const SizedBox(height: 12),

                  // Username
                  Text(
                    displayName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 10, 79, 54),
                    ),
                  ),
                  Text("@${displayName.toLowerCase()}"),

                  const SizedBox(height: 20),

                  // Placeholder graph
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
