import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:renewa/screens/thank_you.dart';
import 'package:renewa/widgets/image_input.dart';

class PassUploadScreen extends StatefulWidget {
  const PassUploadScreen({
    super.key,
    required this.name,
    required this.ticketNo,
    required this.busStop,
    required this.idProofNo,
    required this.existingFrom,
    required this.existingTo,
    required this.address,
  });

  final String name;
  final String ticketNo;
  final String busStop;
  final String idProofNo;
  final String existingFrom;
  final String existingTo;
  final String address;

  @override
  State<PassUploadScreen> createState() => _PassUploadScreenState();
}

class _PassUploadScreenState extends State<PassUploadScreen> {
  File? _selectedImage;
  bool _isSubmitDisabled = true;
  bool _isLoading = false;
  bool _isCheckboxChecked = false;

  void _savePlace() {
    if (_selectedImage == null || !_isCheckboxChecked) {
      return;
    }

    setState(() {
      _isSubmitDisabled = true;
      _isLoading = true;
    });

    _uploadData().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _uploadData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedImage == null) {
      return;
    }

    try {
      final fileName = path.basename(_selectedImage!.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('pass_images/${user.uid}/$fileName');
      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('CCSubmissions').doc(user.uid).set({
        'name': widget.name,
        'ticketNo': widget.ticketNo,
        'busStop': widget.busStop,
        'idProofNo': widget.idProofNo,
        'existingFrom': widget.existingFrom,
        'existingTo': widget.existingTo,
        'address': widget.address,
        'imageUrl': imageUrl,
        'imagePath': _selectedImage!.path,
        'status': 'pending',
        'user_email': user.email,
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const ThankYouScreen()));
    } catch (error) {
      print('Error uploading data: $error');
    }
  }

  void _onCheckboxChanged(bool? newValue) {
    setState(() {
      _isCheckboxChecked = newValue ?? false;
      _isSubmitDisabled = !_isCheckboxChecked || _selectedImage == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ImageInput(
                onPickImage: (image) {
                  setState(() {
                    _selectedImage = image;
                    _isSubmitDisabled = !_isCheckboxChecked;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description (optional)',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isCheckboxChecked,
                  onChanged: _onCheckboxChanged,
                ),
                const Expanded(
                  child: Text(
                    'Your submission will be final and cannot be modified or withdrawn later. Please review your inputs carefully.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:  const Color.fromRGBO(27, 142, 123, 1),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSubmitDisabled
                    ? null
                    : () {
                        if (!_isSubmitDisabled) {
                          _savePlace();
                        }
                      },
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.arrow_forward),
                label: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
