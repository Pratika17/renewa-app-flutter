import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renewa/screens/about_us.dart';


final _firebase = FirebaseAuth.instance;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredName = '';
  var _enteredPassword = '';
  bool _isLoading = false;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

  try {
      setState(() {
        _isLoading=true;
      });
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );


        
        
        await FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).set({
          'username': _enteredName,
          'email': _enteredEmail,
        
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
      setState(() {
        _isLoading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Renewa-bg.png',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 30,
            right: 30,
            child: Column(
              children: [
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                    );
                  },
                  child: const Text('About Us',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ),
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
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isLogin ? 'Login' : 'Registration',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 14, 45, 14),
                              ),
                            ),
                            const SizedBox(height: 30),
                            if (!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.person),
                                  labelText: 'Name',
                                  labelStyle: TextStyle(
                                    color: Color.fromRGBO(26, 86, 76, 1),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 15, 45, 14)),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(255, 21, 45, 27)),
                                  ),
                                ),
                                style: const TextStyle(color: Color.fromARGB(255, 18, 44, 26)),
                                onSaved: (value) {
                                  _enteredName = value!;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.mail),
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Color.fromARGB(255, 19, 43, 30)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromARGB(255, 15, 45, 14)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromARGB(255, 21, 45, 27)),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              style: const TextStyle(color: Color.fromARGB(255, 18, 44, 26)),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty || !value.contains('@') || !value.contains('.com')) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.lock),
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Color.fromARGB(255, 18, 42, 27)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromARGB(255, 20, 47, 26)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromARGB(255, 20, 42, 22)),
                                ),
                              ),
                              obscureText: true,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                            const SizedBox(height: 10),
                            if (_isLoading)
                              const CircularProgressIndicator(),
                            if (!_isLoading)
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(0, 105, 92, 1),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(_isLogin ? 'Login' : 'Sign Up'),
                              ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin ? 'Create an account' : 'I already have an account',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
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
