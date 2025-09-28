import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'firebase_options.dart';
import 'home_screen.dart';
import 'leader_screen.dart' as lb;
import 'news_screen.dart';
import 'publicprofile_screen.dart';
import 'login.dart';
import 'location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

/// Stream-based wrapper to show login or main screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb_auth.User?>(
      stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          final fb_auth.User user = snapshot.data!;

          // Start background location tracking
          startTracking(user.uid);

          // Pass UID to MainHomeScreen
          return MainHomeScreen(userId: user.uid);
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  final String userId; // Pass the UID here

  const MainHomeScreen({super.key, required this.userId});

  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> widgetOptions;

  @override
  void initState() {
    super.initState();

    // Initialize bottom nav screens with UID passed to profile
    widgetOptions = [
      const HomeScreen(),
      const lb.LeaderboardScreen(),
      const NewsScreen(),
      PublicProfileScreen(userId: widget.userId), // ✅ Correctly pass UID
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildIcon(IconData iconData, int index) {
    bool isSelected = _selectedIndex == index;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? const Color.fromARGB(255, 6, 134, 87)
            : Colors.transparent,
      ),
      padding: const EdgeInsets.all(6),
      child: Icon(
        iconData,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BottomNavigationBar(
            backgroundColor: const Color.fromARGB(255, 10, 79, 54),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: const Color.fromARGB(255, 207, 207, 207),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.home, 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.leaderboard, 1),
                label: 'Leaderboard',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.newspaper, 2),
                label: 'News',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.person, 3),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
