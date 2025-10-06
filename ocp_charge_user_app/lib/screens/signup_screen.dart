import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _numberPartController = TextEditingController();
  String _plateCode = 'Select';
  bool _isEv = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _numberPartController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final fakeEmail = "${_nameController.text.trim()}@ocpcharge.com";
        final password = _passwordController.text.trim();

        UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: fakeEmail,
          password: password,
        );

        final uid = cred.user!.uid;
        await FirebaseDatabase.instance.ref("users/$uid").set({
          'name': _nameController.text.trim(),
          'numberPlate': '$_plateCode-${_numberPartController.text.trim()}',
          'isEv': _isEv,
          'createdAt': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User registered successfully! Redirecting to login...'),
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      } on FirebaseAuthException catch (e) {
        String message = "Error: ${e.message}";
        if (e.code == 'email-already-in-use') {
          message = "Account already exists.";
        } else if (e.code == 'weak-password') {
          message = "Password must be at least 6 characters.";
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
        title: const Text('Sign Up'),
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
                        value == null || value.isEmpty ? 'Enter your name' : null,
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
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedBorder,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 16),

                  // Number Plate
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: _plateCode,
                          underline: const SizedBox(),
                          items: [
                            'Select',
                            ...'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''),
                          ].map((code) {
                            return DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _plateCode = val!),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'DUBAI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 90,
                          child: TextFormField(
                            controller: _numberPartController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            decoration: InputDecoration(
                              hintText: '12345',
                              counterText: '',
                              border: inputBorder,
                              enabledBorder: inputBorder,
                              focusedBorder: focusedBorder,
                            ),
                            validator: (value) {
                              if (_plateCode == 'Select') {
                                return 'Choose plate code';
                              }
                              if (value == null || value.isEmpty) {
                                return 'Enter number';
                              }
                              if (value.length > 5) {
                                return 'Max 5 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // EV Toggle
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.electric_car, color: Colors.black54),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Is this an Electric Vehicle?',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: _isEv,
                          onChanged: (val) => setState(() => _isEv = val),
                          activeColor: mainBlue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Create Account'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: mainBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          "Login here",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: mainBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
