import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final fakeEmail = "${_nameController.text.trim()}@ocpcharge.com";
        final password = _passwordController.text.trim();

        UserCredential cred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: fakeEmail, password: password);

        final uid = cred.user!.uid;
        final snapshot =
            await FirebaseDatabase.instance.ref("users/$uid").get();

        if (snapshot.exists) {
          final userData = Map<String, dynamic>.from(snapshot.value as Map);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login successfull Redirecting..."),
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                '/booking',
                arguments: {
                  'name': userData['name'],
                  'numberPlate': userData['numberPlate'],
                  'isEv': userData['isEv'],
                },
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not found in database.")),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = "Login failed: ${e.message}";
        if (e.code == 'user-not-found') {
          message = "No account found with this name.";
        } else if (e.code == 'wrong-password') {
          message = "Invalid password.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF2C6EC6);

    final inputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black),
      borderRadius: BorderRadius.circular(6),
    );

    final focusedBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: mainBlue, width: 2),
      borderRadius: BorderRadius.circular(6),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: mainBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/OCP_logo.png', width: 120),
                  const SizedBox(height: 24),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedBorder,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter your name'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedBorder,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter your password'
                            : null,
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Signup redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don’t have an account yet? ",
                        style: TextStyle(
                          color: mainBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: mainBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
