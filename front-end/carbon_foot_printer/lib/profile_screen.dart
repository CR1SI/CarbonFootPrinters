import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final int pfpIndex;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.pfpIndex,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int _pfpIndex;
  late String _username;

  @override
  void initState() {
    super.initState();
    _pfpIndex = widget.pfpIndex;
    _username = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Back + Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 10, 79, 54),
                      ),
                    ),
                    const SizedBox(width: 48), // placeholder for symmetry
                  ],
                ),
                const SizedBox(height: 20),

                // Icon selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: () {
                        setState(() {
                          _pfpIndex = (_pfpIndex - 1 + 10) % 10;
                        });
                      },
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          Colors.primaries[_pfpIndex % Colors.primaries.length],
                      child: const Icon(Icons.person,
                          size: 50, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: () {
                        setState(() {
                          _pfpIndex = (_pfpIndex + 1) % 10;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                _profileCard(
                  icon: Icons.person,
                  title: "Change Username",
                  onTap: () {},
                ),
                _profileCard(
                  icon: Icons.email,
                  title: "Change Email",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileCard(
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
