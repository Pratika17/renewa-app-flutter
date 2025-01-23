import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/models/place.dart';
import 'package:renewa/screens/thank_you.dart';
import 'package:renewa/widgets/image_input.dart';
import 'package:renewa/widgets/location_input.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class CampaignUploadScreen extends StatefulWidget {
  const CampaignUploadScreen({super.key, required this.campaign});
  final Campaign campaign;

  @override
  State<CampaignUploadScreen> createState() => _CampaignUploadScreenState();
}

class _CampaignUploadScreenState extends State<CampaignUploadScreen> {
  File? _selectedImage;
  PlaceLocation? _pickedLocation;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isAlreadySubmitted = false;
  bool _isCheckboxChecked = false;
  bool _isSubmitting = false; // Add this line
  String? _existingImageUrl;
  String? _existingLocation;
  String? _existingDescription;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySubmitted();
  }

  Future<void> _checkIfAlreadySubmitted() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final userEmail = user.email;
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final username = userSnapshot.docs.first['username'];
      final campaignSnapshot = await FirebaseFirestore.instance
          .collection(widget.campaign.title)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (campaignSnapshot.docs.isNotEmpty) {
        final data = campaignSnapshot.docs.first.data();
        setState(() {
          _isAlreadySubmitted = true;
          _existingImageUrl = data['imageUrl'];
          _existingLocation = data['location'];
          _existingDescription = data['description'];
        });
      }
    }
  }

  Future<void> _uploadData() async {
    if (_selectedImage == null || _pickedLocation == null || !_isCheckboxChecked) {
      return;
    }

    try {
      setState(() {
        _isSubmitting = true; // Set submitting state to true
      });

      // Get the current user
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      // Fetch the username of the current user
      final userEmail = user.email;
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();
      final username = userSnapshot.docs.first['username'];

      final fileName = path.basename(_selectedImage!.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('campaign_images/${widget.campaign.title}/$fileName');
      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();
      var uuid=const Uuid().v4();
      final campaignTitle=widget.campaign.title;
      final datetime=DateTime.now();
      

      await FirebaseFirestore.instance
          .collection('Submissions')
          .doc(uuid)
          .set({
            'campaign_id': campaignTitle,
            'created_at': datetime,
        'photo_url': imageUrl,
        'status':"pending",
        'location': _pickedLocation!.address,
        'description': _descriptionController.text,
        'user_id': username, // Use the fetched username
      });

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => const ThankYouScreen()));
    } catch (e) {
      // Handle errors
    } finally {
      setState(() {
        _isSubmitting = false; // Set submitting state to false
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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
        title: const Text('Upload', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_existingImageUrl != null)
                Center(
                  child: Image.network(_existingImageUrl!),
                ),
              if (_existingImageUrl == null)
                Center(
                  child: ImageInput(
                    onPickImage: (image) {
                      if (!_isAlreadySubmitted) {
                        setState(() {
                          _selectedImage = image;
                        });
                      }
                    },
                  ),
                ),
              const SizedBox(height: 16),
              if (_existingLocation != null)
                Text('Location: $_existingLocation'),
              if (_existingLocation == null)
                LocationInput(
                  onSelectPlace: (location) {
                    if (!_isAlreadySubmitted) {
                      setState(() {
                        _pickedLocation = location;
                      });
                    }
                  },
                ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController..text = _existingDescription ?? '',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description (optional)',
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 16),
              if (!_isAlreadySubmitted)
                Row(
                  children: [
                    Checkbox(
                      value: _isCheckboxChecked,
                      onChanged: (bool? value) {
                        if (!_isAlreadySubmitted) {
                          setState(() {
                            _isCheckboxChecked = value ?? false;
                          });
                        }
                      },
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
                    backgroundColor: const Color.fromRGBO(27, 142, 123, 1),
                    foregroundColor: Colors.white,
                  ),
                
                  onPressed: _isCheckboxChecked && !_isAlreadySubmitted && !_isSubmitting
                      ? _uploadData
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
