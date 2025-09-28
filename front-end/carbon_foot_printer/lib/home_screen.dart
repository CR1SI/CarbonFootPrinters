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

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color.fromARGB(255, 10, 79, 54),
        title: StreamBuilder<DocumentSnapshot>(
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

            // Fallback to 'Guest' if name is null or empty
            final username = (data?['name'] as String?)?.trim().isNotEmpty == true
                ? data!['name']
                : "Guest";

            return Text(
              'Welcome, $username',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Varela',
                fontSize: 32,
              ),
            );
          },
        ),
      ),
      body: const Center(child: Text("Home content here")),
    );
  }
}
