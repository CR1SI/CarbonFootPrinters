import 'package:flutter/material.dart';

// User model (mock data for now, API-ready for later)
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

  // API-friendly factory (for later)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      pfp: json['pfp'],
      country: json['country'],
      transportation: json['transportation'],
      carbonEmission: (json['carbonEmission'] as num).toDouble(),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late List<User> users;

  @override
  void initState() {
    super.initState();

    // Mock user data (replace with API later)
    users = [
      User(name: "Alice", email: "alice@mail.com", pfp: 1, country: "USA", transportation: "Car", carbonEmission: 150.5),
      User(name: "Bob", email: "bob@mail.com", pfp: 2, country: "Canada", transportation: "Bike", carbonEmission: 20.0),
      User(name: "Charlie", email: "charlie@mail.com", pfp: 3, country: "Germany", transportation: "Bus", carbonEmission: 60.2),
      User(name: "Diana", email: "diana@mail.com", pfp: 4, country: "UK", transportation: "Train", carbonEmission: 45.8),
      User(name: "Ethan", email: "ethan@mail.com", pfp: 5, country: "France", transportation: "Plane", carbonEmission: 200.3),
      User(name: "Fiona", email: "fiona@mail.com", pfp: 6, country: "Japan", transportation: "Subway", carbonEmission: 30.7),
      User(name: "George", email: "george@mail.com", pfp: 7, country: "India", transportation: "Rickshaw", carbonEmission: 70.1),
      User(name: "Hannah", email: "hannah@mail.com", pfp: 8, country: "Brazil", transportation: "Walking", carbonEmission: 5.2),
      User(name: "Ian", email: "ian@mail.com", pfp: 9, country: "Australia", transportation: "Carpool", carbonEmission: 40.0),
      User(name: "Jade", email: "jade@mail.com", pfp: 10, country: "Italy", transportation: "Scooter", carbonEmission: 55.6),
      // More mock users if needed...
    ];

    // Sort & keep top 10 (lowest emissions first)
    users.sort((a, b) => a.carbonEmission.compareTo(b.carbonEmission));
    users = users.take(10).toList();
  }

  Widget _buildAvatar(int pfp, String name) {
    // TODO: later map pfp -> icons or asset images
    return CircleAvatar(
      backgroundColor: Colors.green.shade200,
      child: Text(
        name[0], // fallback: first letter of name
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carbon Leaderboard",
        style: TextStyle(
          color: Colors.white,
        ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 10, 79, 54),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: _buildAvatar(user.pfp, user.name),
              title: Text(
                "${index + 1}. ${user.name}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${user.country} | 🚗 ${user.transportation}",
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.eco, color: Colors.green),
                  Text(
                    "${user.carbonEmission.toStringAsFixed(2)} kg CO₂",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
