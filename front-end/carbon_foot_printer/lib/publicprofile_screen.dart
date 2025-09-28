import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_screen.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userId; // Use this to fetch any user

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("User not found")),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final displayName = userData['name'] ?? 'User';
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
                  // Top row: share + settings
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

                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.primaries[pfpIndex % Colors.primaries.length],
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
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
