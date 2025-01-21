import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/models/water_usage_model.dart';
import 'package:renewa/screens/upload_2.dart';
import 'package:renewa/widgets/image_input.dart';

class UploadOneScreen extends StatefulWidget {
  const UploadOneScreen({super.key, required this.campaign});
  final Campaign campaign;

  @override
  State<UploadOneScreen> createState() => _UploadOneScreenState();
}

class _UploadOneScreenState extends State<UploadOneScreen> {
  File? _selectedImage;
  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _previousUsageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _numEmployeesController = TextEditingController();
  bool _isAlreadySubmitted = false;
  String? _existingBillNo;
  String? _existingPreviousUsage;
  String? _existingDescription;
  String? _existingImageUrl;
  String? _existingNumEmployees;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySubmitted();
    _billNoController.addListener(_updateButtonState);
    _previousUsageController.addListener(_updateButtonState);
    _descriptionController.addListener(_updateButtonState);
    _numEmployeesController.addListener(_updateButtonState);
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
          _existingBillNo = data['billNo'];
          _existingPreviousUsage = data['previousUsage'];
          _existingDescription = data['description'];
          _existingImageUrl = data['previousImageUrl'];
          _existingNumEmployees = data['numEmployees'];

          _billNoController.text = _existingBillNo ?? '';
          _previousUsageController.text = _existingPreviousUsage ?? '';
          _descriptionController.text = _existingDescription ?? '';
          _numEmployeesController.text = _existingNumEmployees ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _billNoController.removeListener(_updateButtonState);
    _previousUsageController.removeListener(_updateButtonState);
    _descriptionController.removeListener(_updateButtonState);
    _numEmployeesController.removeListener(_updateButtonState);
    _billNoController.dispose();
    _previousUsageController.dispose();
    _descriptionController.dispose();
    _numEmployeesController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  void _navigateToUploadTwoScreen(WaterUsage usageData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => UploadTwoScreen(
          campaign: widget.campaign,
          previousData: usageData,
        ),
      ),
    ).then((_) {
      // Refresh the state to ensure the data is preserved
      setState(() {});
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
        title: const Text(
          'Upload your previous water usage bill',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
              TextField(
                controller: _billNoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Bill No.',
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _previousUsageController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Previous water level usage',
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _numEmployeesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number of employees in your company',
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description (optional)',
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 16),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  const Color.fromRGBO(27, 142, 123, 1),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (_selectedImage != null || _existingImageUrl != null) &&
                          _billNoController.text.isNotEmpty &&
                          _previousUsageController.text.isNotEmpty &&
                          _numEmployeesController.text.isNotEmpty &&
                          !_isAlreadySubmitted
                      ? () {
                          final usageData = WaterUsage(
                            billNo: _billNoController.text,
                            previousUsage: _previousUsageController.text,
                            currentUsage: '',
                            description: _descriptionController.text,
                            previousImageUrl: _selectedImage?.path ?? _existingImageUrl!,
                            currentImageUrl: '',
                            numEmployees: _numEmployeesController.text,
                          );
                
                          _navigateToUploadTwoScreen(usageData);
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
