import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _progress = 0.4; // Example progress (40%)
  int _selectedGoal = 50; // Default goal in kg
  final List<int> _goalOptions = [10, 25, 50, 100, 200];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Custom rounded AppBar
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 10, 79, 54),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: StreamBuilder<DocumentSnapshot>(
                stream: docRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      "Welcome, @User",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Varela',
                        fontSize: 32,
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  final username = (data?['name'] as String?)?.trim().isNotEmpty == true
                      ? data!['name']
                      : "Guest";

                  return Text(
                    'Welcome, $username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Varela',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Section Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Your Weekly Goal",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 10, 79, 54),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Animated Goal Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Animated circular progress
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: _progress),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, _) {
                      return SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 10, 79, 54),
                              ),
                            ),
                            Center(
                              child: Text(
                                "${(value * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 10, 79, 54),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 20),

                  // Goal info + selector
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${(_progress * _selectedGoal).toStringAsFixed(1)} / $_selectedGoal kg",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 10, 79, 54),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButton<int>(
                          value: _selectedGoal,
                          underline: const SizedBox(),
                          items: _goalOptions
                              .map((g) => DropdownMenuItem(
                                    value: g,
                                    child: Text("$g kg"),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedGoal = value;
                                _progress = 0.0; // reset progress when goal changes
                              });

                              // Animate progress filling back up (example)
                              Future.delayed(const Duration(milliseconds: 300), () {
                                setState(() {
                                  _progress = 0.4; // replace with real calculation
                                });
                              });
                            }
                          },
                        ),
                      ],
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
