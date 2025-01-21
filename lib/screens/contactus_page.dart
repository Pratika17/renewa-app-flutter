import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  ContactUsScreen({super.key});

  final _form = GlobalKey<FormState>();

  late final String _enteredName;
  late final String _enteredNumber;
  late final String _enteredComments;

  void _submit(BuildContext context) async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    try {
      final authenticatedUser = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('ContactUs')
          .doc(authenticatedUser.uid)
          .set({
        'Name': _enteredName,
        'ContactNumber': _enteredNumber,
        'Comments': _enteredComments,
      });

      Navigator.of(context).pop(); // Pop the screen after successful submission
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Submit failed.'),
        ),
      );
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
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Icon(Icons.close,
                                    color: Colors.black),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contact us',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(
                                        255,
                                        14,
                                        45,
                                        14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'We’re here to help you',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Your Name',
                                labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 19, 43, 30)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 15, 45, 14)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 21, 45, 27)),
                                ),
                              ),
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 18, 44, 26)),
                              onSaved: (value) {
                                _enteredName = value!;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your name.';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Your Contact Number',
                                labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 19, 43, 30)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 15, 45, 14)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 21, 45, 27)),
                                ),
                              ),
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 18, 44, 26)),
                              keyboardType: TextInputType.phone,
                              onSaved: (value) {
                                _enteredNumber = value!;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your contact number.';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Your comments here!',
                                labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 19, 43, 30)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 15, 45, 14)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 21, 45, 27)),
                                ),
                              ),
                              maxLines: 5,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 18, 44, 26)),
                              onSaved: (value) {
                                _enteredComments = value!;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your comments.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 105, 92, 1),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _submit(context),
                              child: const Text('Submit'),
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
