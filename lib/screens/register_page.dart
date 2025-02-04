import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renewa/screens/about_us.dart';
import 'package:renewa/screens/contactus_page.dart';

final _firebaseAuth = FirebaseAuth.instance;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _email = '';
  var _password = '';
  var _name = '';
  String _selectedRole = 'Citizen'; // Default value
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Login logic
        await _firebaseAuth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else {
        // Sign-up logic
        final userCredentials =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Add user to Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredentials.user!.uid)
            .set({
          'user_name': _name,
          'user_email': _email,
          'subscription_type': 'free',
          'credits': 0,
          'recycle_award': 0,
          'recycle_role': _selectedRole, // Save selected role
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/Renewa-bg.png',
            fit: BoxFit.cover,
          ),
          // About Us Button
          Positioned(
            top: 30,
            right: 30,
            child: Row(
              children: [
                TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>const ContactUsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Contact Us',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutUsScreen()),
                    );
                  },
                  child: const Text(
                    'About Us',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          // Form Container
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              _isLogin ? 'Login' : 'Sign Up',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 14, 45, 14),
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Name Field (Only for Registration)
                            if (!_isLogin)
                              TextFormField(
                                key: const ValueKey('name'),
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.person),
                                  labelText: 'Name',
                                  labelStyle: TextStyle(
                                    color: Color.fromRGBO(26, 86, 76, 1),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your name.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _name = value!;
                                },
                              ),
                            const SizedBox(height: 10),
                            if (!_isLogin)
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.work),
                                  labelText: 'Recycle Role',
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 19, 43, 30),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Citizen',
                                    child: Text('Citizen'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Collection Worker',
                                    child: Text('Collection Worker'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Dealer',
                                    child: Text('Dealer'),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedRole = newValue;
                                    });
                                  }
                                },
                              ),
                            const SizedBox(height: 10),
                            // Email Field
                            TextFormField(
                              key: const ValueKey('email'),
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.mail),
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 19, 43, 30),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                        .hasMatch(value)) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _email = value!;
                              },
                            ),
                            const SizedBox(height: 10),
                            // Password Field
                            TextFormField(
                              key: const ValueKey('password'),
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.lock),
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 18, 42, 27),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _password = value!;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Loading Indicator or Submit Button
                            if (_isLoading) const CircularProgressIndicator(),
                            if (!_isLoading)
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(0, 105, 92, 1),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(_isLogin ? 'Login' : 'Sign Up'),
                              ),
                            const SizedBox(height: 10),
                            // Switch Between Login/Sign Up
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? 'Create an account'
                                    : 'I already have an account',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
