import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Color.fromARGB(255, 10, 79, 54),
  appBar: AppBar(
  toolbarHeight: 100,
title: Text('Settings',
style: TextStyle(
      color: Colors.white,
      fontFamily: 'Varela',  
      fontSize: 48,             
      ),
),
backgroundColor: const Color.fromARGB(255, 10, 79, 54),
  ),

);
  }
}