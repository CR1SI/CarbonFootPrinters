import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _authUser;
  late DocumentReference _userDoc;

  @override
  void initState() {
    super.initState();
    _authUser = FirebaseAuth.instance.currentUser!;
    _userDoc = FirebaseFirestore.instance.collection('users').doc(_authUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDoc.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final username = data['name'] ?? 'Guest';
        final pfpIndex = data['pfp'] ?? 0;

        return Scaffold(
          backgroundColor: const Color(0xFF0A4F36),
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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A4F36),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A4F36)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Profile picture selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_left),
                          onPressed: () {
                            final newIndex = (pfpIndex - 1 + 10) % 10;
                            _userDoc.update({'pfp': newIndex});
                          },
                        ),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.primaries[pfpIndex % Colors.primaries.length],
                          child: const Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_right),
                          onPressed: () {
                            final newIndex = (pfpIndex + 1) % 10;
                            _userDoc.update({'pfp': newIndex});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Change Username
                    _profileCard(
                      icon: Icons.person,
                      title: "Change Username",
                      onTap: () async {
                        final controller = TextEditingController(text: username);
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Change Username"),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(labelText: "New username"),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, controller.text),
                                child: const Text("Save"),
                              ),
                            ],
                          ),
                        );
                        if (newName != null && newName.isNotEmpty) {
                          await _userDoc.update({'name': newName});
                        }
                      },
                    ),

                    // Change Email
                    _profileCard(
                      icon: Icons.email,
                      title: "Change Email",
                      onTap: () async {
                        final emailController = TextEditingController();

                        final newEmail = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Change Email"),
                              content: TextField(
                                controller: emailController,
                                decoration: const InputDecoration(labelText: "New Email"),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, emailController.text.trim()),
                                  child: const Text("Update"),
                                ),
                              ],
                            );
                          },
                        );

                        if (newEmail != null && newEmail.isNotEmpty) {
               

                            // Update Firestore JSON
                            await _userDoc.update({'email': newEmail});

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Email updated successfully."),
                                ),
                              );
                            }
                          }
                        }
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _profileCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF0A4F36)),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0A4F36),
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF0A4F36)),
          onTap: onTap,
        ),
      ),
    );
  }
}
