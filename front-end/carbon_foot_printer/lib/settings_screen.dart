import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'firebase_service.dart';
import 'login.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService(); // Firebase service

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
                // Header with Title (left) + Close (right) — no back arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 10, 79, 54),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Profile
                _settingsCard(
                  context,
                  icon: Icons.person,
                  title: "Profile",
                  onTap: () {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ProfileScreen(),
  ),
);
                  },
                ),
                _settingsCard(
                  context,
                  icon: Icons.lock,
                  title: "Change Password",
                  onTap: () {},
                ),
                _settingsCard(
                  context,
                  icon: Icons.notifications,
                  title: "Notifications",
                  onTap: () {},
                ),

                // Dark mode toggle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text("Dark Mode"),
                      secondary: const Icon(Icons.dark_mode),
                      value: false,
                      onChanged: (val) {},
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Log Out Button
                OutlinedButton(
                  onPressed: () async {
                    await _authService.signOut(); // Firebase logout

                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false, // removes all previous routes
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 10, 79, 54), width: 2),
                  ),
                  child: const Text(
                    "LOG OUT",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 10, 79, 54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
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
