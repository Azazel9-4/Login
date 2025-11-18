import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'song_lyrics_display/song_lyrics_display.dart'; // Correct import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<void> _login() async {
    final snapshot = await users
        .where('username', isEqualTo: _usernameController.text)
        .where('password', isEqualTo: _passwordController.text)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Get first and last name from Firestore
      final userData = snapshot.docs.first.data() as Map<String, dynamic>;
      final firstName = userData['first_name'] ?? '';
      final lastName = userData['last_name'] ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          content: Text(
            'Login Successful! Welcome, $firstName $lastName!',
            style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Navigate to the song_lyrics_display app
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SongLyricsDisplayApp(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: const Text(
            'Invalid username or password!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E2626),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1DB954)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        title: const Text(
          'Aexor',
          style: TextStyle(
            color: Color(0xFF1DB954),
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 50),
              // Username Field
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Color(0xFFB3B3B3)),
                  filled: true,
                  fillColor: Colors.black,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFB3B3B3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF1DB954), width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Color(0xFFB3B3B3)),
                  filled: true,
                  fillColor: Colors.black,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFB3B3B3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF1DB954), width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sign Up Text
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(
                    color: Color(0xFF1DB954),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
