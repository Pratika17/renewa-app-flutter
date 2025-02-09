import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renewa/widgets/location_input.dart';

class DealerRegistrationScreen extends StatefulWidget {
  const DealerRegistrationScreen({super.key});

  @override
  State<DealerRegistrationScreen> createState() =>
      _DealerRegistrationScreenState();
}

class _DealerRegistrationScreenState extends State<DealerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _pickedLocation;
  String? _pickedLocationAdd;
  Map<String, dynamic>? _pickedLocationsMap;
  String? _existingEmail;
  bool _isSubmitting = false;
  bool _isAlreadyRegistered = false;
  String? _locationImage;
  String? _existingDocId;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      _existingEmail = user.email;
    });

    final dealerSnapshot = await FirebaseFirestore.instance
        .collection('Dealers')
        .where('email', isEqualTo: user.email)
        .get();

    if (dealerSnapshot.docs.isNotEmpty) {
      final doc = dealerSnapshot.docs.first;

      final data = dealerSnapshot.docs.first.data();
      setState(() {
        _isAlreadyRegistered = true;
        _existingDocId = doc.id;
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _pickedLocation = data['location'];
        final latLong = _pickedLocation?.split(',');
        if (latLong != null && latLong.length == 2) {
          final lat = double.tryParse(latLong[0]);
          final lng = double.tryParse(latLong[1]);

          if (lat != null && lng != null) {
            _locationImage =
                'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=YOUR_API_KEY';
            _pickedLocationsMap = {'latitude': lat, 'longitude': lng};
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitData() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _pickedLocation == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    _formKey.currentState!.save();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      final userEmail = user.email;
      final latLong = _pickedLocation!.split(',');
      final latitude = double.parse(latLong[0]);
      final longitude = double.parse(latLong[1]);
      if (_isAlreadyRegistered && _existingDocId != null) {
        await FirebaseFirestore.instance
            .collection('Dealers')
            .doc(_existingDocId)
            .set({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'location': _pickedLocationAdd,
          'locations': {'latitude': latitude, 'longitude': longitude},
          'user_email': userEmail,
        });
      } else {
        await FirebaseFirestore.instance.collection('Dealers').add({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'location': _pickedLocationAdd,
          'locations': {'latitude': latitude, 'longitude': longitude},
          'user_email': userEmail,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data Saved successfully')),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data: $e')),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _editData() {
    setState(() {
      _isAlreadyRegistered = false;
      _locationImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool canSubmit = !_isAlreadyRegistered &&
        _formKey.currentState?.validate() == true &&
        _pickedLocation != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Dealer Registration',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                enabled: !_isAlreadyRegistered,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                enabled: !_isAlreadyRegistered,
              ),
              const SizedBox(height: 16),
              if (_isAlreadyRegistered && _locationImage != null)
                SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: Image.network(
                      _locationImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'Could not load image.',
                          textAlign: TextAlign.center,
                        );
                      },
                    )),
              if (!_isAlreadyRegistered)
                LocationInput(
                  onSelectPlace: (location) {
                    setState(() {
                      _pickedLocation =
                          '${location.latitude},${location.longitude}';
                      _pickedLocationAdd = location.address;
                    });
                  },
                ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _existingEmail,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(27, 142, 123, 1),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: canSubmit && !_isSubmitting ? _submitData : null,
                    icon: _isSubmitting
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Icon(Icons.arrow_forward),
                    label: _isSubmitting
                        ? const Text("Submitting")
                        : const Text('Register'),
                  ),
              
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
