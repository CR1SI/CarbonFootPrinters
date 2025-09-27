import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'leader_screen.dart';
import 'news_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
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
      home: LoginScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> widgetOptions = const [
    HomeScreen(),
    LeaderboardScreen(),
    NewsScreen(),
    ProfileScreen(),
  ];

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
        color: isSelected ? const Color.fromARGB(255, 6, 134, 87) : Colors.transparent, // white bg if selected
      ),
      padding: const EdgeInsets.all(6), // spacing so icon doesn’t touch edges
      child: Icon(
        iconData,
        color: const Color.fromARGB(255, 255, 255, 255)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 10, 79, 54),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white, // still needed for label color
        unselectedItemColor: const Color.fromARGB(255, 207, 207, 207),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
