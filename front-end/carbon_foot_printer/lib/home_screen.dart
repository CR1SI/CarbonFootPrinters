import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final Future<double> totalEmissionsSaved = Future.value(94820); // in tons

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: Column(
          children: [
            // Top header
            Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0A4F36),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<DocumentSnapshot>(
                stream: docRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      "Welcome, @User",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  final username =
                      (data?['name'] as String?)?.trim().isNotEmpty == true
                          ? data!['name']
                          : "Guest";

                  return Text(
                    "Welcome, $username",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),

            // Underpart: Total Emissions Saved
            FutureBuilder<double>(
              future: totalEmissionsSaved,
              builder: (context, snapshot) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8), // narrower than header
                  decoration: BoxDecoration(
                    color: const Color(0xFF068657),
                    borderRadius: BorderRadius.circular(20), // all corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  child: Center(
                    child: Text(
                      snapshot.hasData
                          ? "Total Emissions Saved: ${snapshot.data!.toStringAsFixed(0)} tons of CO₂"
                          : "Loading emissions data...",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Your Weekly Goal",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A4F36),
              ),
            ),
            const SizedBox(height: 12),

            // Goal card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Progress circle (placeholder, replace with real data)
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: 20 / 50, // progress (dummy data)
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF0A4F36),
                          ),
                        ),
                        const Center(
                          child: Text(
                            "40%",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Goal info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "20.0 / 50 kg",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A4F36),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButton<int>(
                        value: 50,
                        items: const [
                          DropdownMenuItem(
                            value: 25,
                            child: Text("25 kg"),
                          ),
                          DropdownMenuItem(
                            value: 50,
                            child: Text("50 kg"),
                          ),
                          DropdownMenuItem(
                            value: 100,
                            child: Text("100 kg"),
                          ),
                        ],
                        onChanged: (value) {
                          // TODO: connect to backend to update goal
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
