import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      await users.add({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
      });
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Account Successfully Created!',
        style: TextStyle(color: Colors.black)),
    backgroundColor: const Color(0xFF1DB954),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(12),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            Navigator.pushReplacementNamed(context, '/'); // Back to HomeScreen
          },
        ),
        title: const Text(
          'Aexor',
          style: TextStyle(
            color: Color(0xFF1DB954),
            fontWeight: FontWeight.bold, fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 15),
              const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 40),

              // ===== Form Fields =====
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_firstNameController, 'First Name'),
                    const SizedBox(height: 16),
                    _buildTextField(_lastNameController, 'Last Name'),
                    const SizedBox(height: 16),
                    _buildTextField(_usernameController, 'Username'),
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, 'Password',
                        obscureText: true),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ===== Sign Up Button =====
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ===== Login Text =====
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "Already have an account? Log in",
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

  // ===== Helper TextField Builder =====
Widget _buildTextField(TextEditingController controller, String label,
    {bool obscureText = false}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    style: const TextStyle(color: Colors.white),
    validator: (value) => value!.isEmpty ? 'Enter $label' : null,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFB3B3B3)),
      filled: true,
      fillColor: Colors.black,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB3B3B3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1DB954), width: 2),
      ),
      // 👇 Keep rounded corners on error
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1DB954)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1DB954), width: 2),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFF5252)),
    ),
  );
}
}