import 'package:flutter/material.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      body: Center(
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
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 10, 79, 54),
                ),
              ),
              const SizedBox(height: 20),

              // Profile Button
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profile"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(
                        username: "GuestUser",
                        pfpIndex: 0,
                      ),
                    ),
                  );
                },
              ),
              const Divider(),

              // Change Password
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Change Password"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              const Divider(),

              // Notifications
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text("Notifications"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              const Divider(),

              // Dark Mode Toggle
              SwitchListTile(
                title: const Text("Dark Mode"),
                secondary: const Icon(Icons.dark_mode),
                value: false,
                onChanged: (val) {
                  // hook up theme later
                },
              ),
              const SizedBox(height: 20),

              // Log Out Button
              OutlinedButton(
                onPressed: () {
                  // logout logic here
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("LOG OUT"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
