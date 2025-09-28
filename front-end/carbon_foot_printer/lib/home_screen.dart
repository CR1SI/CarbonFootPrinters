import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedGoal = 50; // default goal

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
        preferredSize: const Size.fromHeight(200),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Your Weekly Goal",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A4F36),
              ),
            ),
            const SizedBox(height: 30),

            // Big Dashboard Circle
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 240,
                      width: 240,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 20 / _selectedGoal),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 22, // thicker
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0A4F36),
                            ),
                            strokeCap: StrokeCap.round, // beveled/rounded ends
                          );
                        },
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${((20 / _selectedGoal) * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A4F36),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "20.0 / $_selectedGoal kg",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A4F36),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Goal Selector Dropdown
            DropdownButton<int>(
              value: _selectedGoal,
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
                setState(() {
                  _selectedGoal = value!;
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
