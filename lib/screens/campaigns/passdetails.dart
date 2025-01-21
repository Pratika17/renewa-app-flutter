
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renewa/screens/campaigns/pass_upload.dart';

class PassDetailsScreen extends StatefulWidget {
  const PassDetailsScreen({super.key});

  @override
  State<PassDetailsScreen> createState() {
    return _PassDetailsScreenState();
  }
}

class _PassDetailsScreenState extends State<PassDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ticketNoController = TextEditingController();
  final TextEditingController _busStopController = TextEditingController();
  final TextEditingController _idProofNoController = TextEditingController();
  final TextEditingController _existingFromController = TextEditingController();
  final TextEditingController _existingToController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isAlreadySubmitted = false;

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

    final userSnapshot = await FirebaseFirestore.instance
        .collection('Clean Commute')
        .doc(user.uid)
        .get();

    if (userSnapshot.exists) {
      final data = userSnapshot.data()!;
      setState(() {
        _isAlreadySubmitted = true;
        _nameController.text = data['name'];
        _ticketNoController.text = data['ticketNo'];
        _busStopController.text = data['busStop'];
        _idProofNoController.text = data['idProofNo'];
        _existingFromController.text = data['existingFrom'];
        _existingToController.text = data['existingTo'];
        _addressController.text = data['address'];
// Assuming the image path is stored in Firestore
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 16, 40, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Travel Pass Details',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 26),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Name",
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _ticketNoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Ticket Number",
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _busStopController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Bus Stop",
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _idProofNoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "ID Proof No.",
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _existingFromController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Existing From",
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _existingToController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Existing To",
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Address",
                ),
                enabled: !_isAlreadySubmitted,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isAlreadySubmitted
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => PassUploadScreen(
                                  name: _nameController.text,
                                  ticketNo: _ticketNoController.text,
                                  busStop: _busStopController.text,
                                  idProofNo: _idProofNoController.text,
                                  existingFrom: _existingFromController.text,
                                  existingTo: _existingToController.text,
                                  address: _addressController.text,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      maximumSize: const Size(200, 50),
                      backgroundColor: const Color.fromRGBO(27, 142, 123, 1),
                      foregroundColor: Colors.white,
                    ),
                    child:const Text('Next'),
                  ),
                ],
              ),
              const SizedBox(height: 30), // Add some space after the button
            ],
          ),
        ),
      ),
    );
  }
}
