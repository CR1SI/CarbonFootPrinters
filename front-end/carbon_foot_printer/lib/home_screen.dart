import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
title: Text('Welcome, USER'),
backgroundColor: const Color.fromARGB(255, 255, 255, 255),
),
    );
  }
}