import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _form = GlobalKey<FormState>();
  late String _enteredName;
  late String _enteredNumber;
  late String _enteredComments;
  bool _isSubmitting = false;

  void _submit(BuildContext context) async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authenticatedUser = FirebaseAuth.instance.currentUser;
      Map<String, dynamic> submissionData = {
        'entered_name': _enteredName,
        'contact_number': _enteredNumber,
        'comments': _enteredComments,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'logged_in': authenticatedUser != null ? 'yes' : 'no', // Add logged_in field
      };

      if (authenticatedUser != null) {
        final userEmail = authenticatedUser.email;
        submissionData['user_email'] = userEmail;

        // Fetch user name from 'Users' collection based on email
        final userQuery = await FirebaseFirestore.instance
            .collection('Users')
            .where('user_email', isEqualTo: userEmail)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data() as Map<String, dynamic>;
          final userName = userData['user_name'];
          submissionData['user_name'] = userName;
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User data not found.  Submit failed.'),
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
          return; // Exit the function if user data is not found
        }
      }

      await FirebaseFirestore.instance.collection('ContactUs').add(submissionData);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully submitted!'),
        ),
      );

      Navigator.of(context).pop(); // Pop the screen after successful submission
    } on FirebaseException catch (error) {  // Changed exception type
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Submit failed.'),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
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
                              onPressed: _isSubmitting ? null : () => _submit(context),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Submit'),
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