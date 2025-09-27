import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "LOGIN",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 10, 79, 54),
                ),
              ),
              const SizedBox(height: 20),

              // Username field
              TextField(
                decoration: InputDecoration(
                  labelText: "Username:",
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password field
              TextField(
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: "Password:",
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Row with checkbox + forgot password
              Row(
                children: [
                  Checkbox(
                    value: _showPassword,
                    onChanged: (value) {
                      setState(() {
                        _showPassword = value ?? false;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 10, 79, 54),
                  ),
                  const Text("Show Password"),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Sign In button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color.fromARGB(255, 10, 79, 54), width: 2),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sign In clicked")),
                  );
                },
                child: const Text(
                  "SIGN IN",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 10, 79, 54),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account? "),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Go to Sign Up page")),
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
