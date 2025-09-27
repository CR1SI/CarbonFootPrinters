import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart'; // optional if you have helper methods

class User {
  final String name;
  final String email;
  final int pfp;
  final String country;
  final String transportation;
  final double carbonEmission;

  User({
    required this.name,
    required this.email,
    required this.pfp,
    required this.country,
    required this.transportation,
    required this.carbonEmission,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? "Unknown",
      email: json['email'] ?? "",
      pfp: json['pfp'] ?? 0,
      country: json['country'] ?? "Unknown",
      transportation: json['transportation'] ?? "Unknown",
      carbonEmission: (json['carbonEmission'] ?? 0).toDouble(),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<User>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _fetchLeaderboard();
  }

  Future<List<User>> _fetchLeaderboard() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    // Map Firestore docs to User objects
    List<User> users = snapshot.docs.map((doc) {
      return User.fromJson(doc.data());
    }).toList();

    // Sort by carbonEmission (lowest first)
    users.sort((a, b) => a.carbonEmission.compareTo(b.carbonEmission));

    // Return top 10
    return users.take(10).toList();
  }

  Widget _buildAvatar(int pfp, String name) {
    // Placeholder avatar: first letter of name
    return CircleAvatar(
      backgroundColor: Colors.green.shade200,
      child: Text(
        name.isNotEmpty ? name[0] : "?",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Carbon Leaderboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      ),
      body: FutureBuilder<List<User>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: _buildAvatar(user.pfp, user.name),
                  title: Text(
                    "${index + 1}. ${user.name}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${user.country} | 🚗 ${user.transportation}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.eco, color: Colors.green),
                      Text(
                        "${user.carbonEmission.toStringAsFixed(2)} kg CO₂",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
