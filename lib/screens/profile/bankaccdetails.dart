import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BankAccDetailsScreen extends StatefulWidget {
  const BankAccDetailsScreen({super.key});

  @override
  State<BankAccDetailsScreen> createState() {
    return _BankAccDetailsScreenState();
  }
}

class _BankAccDetailsScreenState extends State<BankAccDetailsScreen> {
  final _fullNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchCodeController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
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
      final userData = await FirebaseFirestore.instance
          .collection('bankDetails')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _fullNameController.text = userData['fullName'];
          _accountNumberController.text = userData['accountNumber'];
          _bankNameController.text = userData['bankName'];
          _branchCodeController.text = userData['branchCode'];
          _branchNameController.text = userData['branchName'];
          _addressController.text = userData['address'];
          _emailController.text = userData['email'];
          _dobController.text = userData['dob'];
        });
      }
    } catch (e) {
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

      await FirebaseFirestore.instance
          .collection('bankDetails')
          .doc(user.uid)
          .set({
        'fullName': _fullNameController.text,
        'accountNumber': _accountNumberController.text,
        'bankName': _bankNameController.text,
        'branchCode': _branchCodeController.text,
        'branchName': _branchNameController.text,
        'address': _addressController.text,
        'email': _emailController.text,
        'dob': _dobController.text,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update details. Please try again.')));
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 16, 40, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Details',
                      style:
                          TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: false,
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        hintText: "Full Name",
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _accountNumberController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: false,
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        hintText: "Bank Account Number",
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _bankNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: false,
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        hintText: "Bank Name",
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _branchCodeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: false,
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        hintText: "Branch Code",
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _branchNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: false,
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        hintText: "Branch Name",
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: false,
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        hintText: "Address",
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: false,
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        hintText: "Email",
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
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        hintText: "Date Of Birth",
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _submitDetails,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            maximumSize: const Size(200, 50),
                            backgroundColor:
                                const Color.fromRGBO(27, 142, 123, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _branchCodeController.dispose();
    _branchNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
