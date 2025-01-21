import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/models/water_usage_model.dart';
import 'package:renewa/screens/thank_you.dart';
import 'package:renewa/widgets/image_input.dart';
import 'package:path/path.dart' as path;

class UploadTwoScreen extends StatefulWidget {
  const UploadTwoScreen({super.key, required this.campaign, required this.previousData});
  final Campaign campaign;
  final WaterUsage previousData;

  @override
  State<UploadTwoScreen> createState() => _UploadTwoScreenState();
}

class _UploadTwoScreenState extends State<UploadTwoScreen> {
  File? _selectedImage;
  final TextEditingController _currentUsageController = TextEditingController();
  bool _isSubmitDisabled = true;
  bool _isLoading = false;
  bool _isCheckboxChecked = false;
  bool _isAlreadySubmitted = false;
  String? _existingImageUrl;
  String? _existingCurrentUsage;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySubmitted();
    _currentUsageController.addListener(_updateSubmitButtonState);
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
      final campaignSnapshot = await FirebaseFirestore.instance
          .collection(widget.campaign.title)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (campaignSnapshot.docs.isNotEmpty) {
        final data = campaignSnapshot.docs.first.data();
        setState(() {
          _isAlreadySubmitted = true;
          _existingCurrentUsage = data['currentUsage'];
          _existingImageUrl = data['currentImageUrl'];

          _currentUsageController.text = _existingCurrentUsage ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _currentUsageController.removeListener(_updateSubmitButtonState);
    _currentUsageController.dispose();
    super.dispose();
  }

  void _updateSubmitButtonState() {
    setState(() {
      _isSubmitDisabled = _currentUsageController.text.isEmpty || !_isCheckboxChecked;
    });
  }

  Future<void> _uploadImage(File image, String userId, String field) async {
    final fileName = path.basename(image.path);
    final destination = '${widget.campaign.title}/$userId/$field/$fileName';
    final Reference ref = FirebaseStorage.instance.ref(destination);
    await ref.putFile(image);
    final String url = await ref.getDownloadURL();
    if (field == 'currentImageUrl') {
      _existingImageUrl = url;
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToThankYouScreen();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToThankYouScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const ThankYouScreen(),
      ),
    ).then((_) {
      // Refresh the state to ensure the data is preserved
      setState(() {});
    });
  }

  Future<void> _saveDataToFirestore(String userId, WaterUsage data) async {
    final CollectionReference campaignRef = FirebaseFirestore.instance.collection(widget.campaign.title);
    final QuerySnapshot campaignSnapshot = await campaignRef.where('userId', isEqualTo: userId).get();
    
    if (campaignSnapshot.docs.isNotEmpty) {
      final String docId = campaignSnapshot.docs.first.id;
      await campaignRef.doc(docId).update({
        'currentUsage': data.currentUsage,
        'currentImageUrl': data.currentImageUrl,
      });
    } else {
      await campaignRef.add({
        'userId': userId,
        'billNo': data.billNo,
        'previousUsage': data.previousUsage,
        'currentUsage': data.currentUsage,
        'description': data.description,
        'previousImageUrl': data.previousImageUrl,
        'currentImageUrl': data.currentImageUrl,
        'numEmployees': data.numEmployees,
      });
    }
  }

  void _submitData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      final userId = user.uid;

      if (_selectedImage != null) {
        await _uploadImage(_selectedImage!, userId, 'currentImageUrl');
      }

      final currentUsage = _currentUsageController.text;
      final WaterUsage usageData = widget.previousData.copyWith(
        currentUsage: currentUsage,
        currentImageUrl: _existingImageUrl!,
      );

      await _saveDataToFirestore(userId, usageData);

      final int currentUsageInt = int.parse(currentUsage);
      final int numEmployeesInt = int.parse(usageData.numEmployees);

      if (numEmployeesInt >= 50 && numEmployeesInt <= 100) {
        if (currentUsageInt < 140000) {
          _showDialog('Congratulations', 'You are eligible for a reward. Sanitary charges will be free.');
        } else {
          _showDialog('Uh-Oh', 'Sorry your usage is not eligible for a reward.');
        }
      } else if (numEmployeesInt >= 500 && numEmployeesInt <= 1000) {
        if (currentUsageInt < 740000) {
          _showDialog('Congratulations', 'You are eligible for a reward. Sanitary charges will be free.');
        } else {
          _showDialog('Uh-Oh', 'Sorry your usage is not eligible for a reward.');
        }
      } else {
        _showDialog('Success', 'Your data has been submitted successfully!');
      }
    } catch (e) {
      print('An error occurred while submitting data: $e');
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Upload your current water usage bill',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageInput(
                onPickImage: (pickedImage) {
                  setState(() {
                    _selectedImage = pickedImage;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentUsageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Current Water Usage (liters)'),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('I confirm the information provided is correct'),
                value: _isCheckboxChecked,
                onChanged: !_isAlreadySubmitted
                    ? (bool? value) {
                        setState(() {
                          _isCheckboxChecked = value ?? false;
                          _updateSubmitButtonState();
                        });
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  const Color.fromRGBO(27, 142, 123, 1),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isSubmitDisabled || _isLoading
                      ? null
                      : _submitData,
                  icon: _isLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.check),
                  label: _isLoading
                      ? const Text('Submitting...')
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
