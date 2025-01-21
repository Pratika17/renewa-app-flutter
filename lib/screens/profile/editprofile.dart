import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:renewa/widgets/image_input.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() {
    return _EditProfileScreenState();
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  File? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userData.exists) {
        setState(() {
          _nameController.text = userData['name'];
          _phoneController.text = userData['phone'];
          _dobController.text = userData['dob'];
          _imageUrl = userData['imageUrl'];
        });
      }
    } catch (e) {
      // Handle errors appropriately in your application
      print('Error fetching user details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      String? imageUrl = _imageUrl;

      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance.ref().child('user_images').child('${user.uid}.jpg');
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'imageUrl': imageUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile. Please try again.')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(0, 0, 0, 1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(left: 40, right: 40.0, top: 16.0, bottom: 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 26),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: false,
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      hintText: "Name",
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: false,
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      hintText: "Phone Number",
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: false,
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      hintText: "Date of Birth",
                    ),
                  ),
                  const SizedBox(height: 30),
                  ImageInput(
                    onPickImage: (value) {
                      _selectedImage = value;
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_imageUrl != null)
                    Center(
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Take a picture e.g., aadhar, income tax etc',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _submitDetails,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 16, bottom: 16, right: 24, left: 24),
                          maximumSize: const Size(200, 50),
                          backgroundColor: const Color.fromRGBO(27, 142, 123, 1),
                          foregroundColor: Colors.white,
                        ),
                        child:const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
