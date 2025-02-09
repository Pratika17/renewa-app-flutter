import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:renewa/main.dart';
import 'package:renewa/screens/newFeatures/onboarding_screen.dart';

// Replace this import with the actual path to your RegistrationScreen.
import 'package:renewa/screens/register_page.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _acknowledged = false;
  bool _isDeleting = false;

  /// Deletes documents in a given collection where the field 'user_email' matches [userEmail]
  Future<void> _deleteDocumentsInCollection(String collectionName, String userEmail) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('user_email', isEqualTo: userEmail)
        .get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final String? userEmail = user.email;
      if (userEmail == null) return;

      // List of collections to delete documents from.
      final List<String> collectionsToDelete = [
        "Submissions",
        "QSubmissions",
        "CCsubmissions",
        "Dealers",
        "Orders",
      ];

      // Inform the user that deletion may take a while.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This may take a long time. You will be logged out once it is done."),
          duration: Duration(seconds: 3),
        ),
      );

      // Delete all documents in each specified collection.
      for (String collectionName in collectionsToDelete) {
        await _deleteDocumentsInCollection(collectionName, userEmail);
      }

      // Delete the user's document in the Users collection.
      final QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_email', isEqualTo: userEmail)
          .get();
      for (var doc in userDocs.docs) {
        await doc.reference.delete();
      }

      // Delete the user's authentication account.
      await user.delete();

      // Instead of pushNamedAndRemoveUntil, push RegistrationScreen using MaterialPageRoute.
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AuthStateScreen()),
        );
      }
    } catch (e) {
      // Show an error message if something goes wrong.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete account: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isDeleting
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "This may take a long time. You will be logged out once it is done.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Warning!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your account details and all your data (including documents in Submissions, QSubmissions, CCsubmissions, Dealers, and Orders collections) will be deleted from our systems within 24 hours. This action cannot be undone.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _acknowledged,
                        onChanged: (value) {
                          setState(() {
                            _acknowledged = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "Yes, I acknowledge that this action cannot be undone.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _acknowledged ? Colors.red : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      ),
                      onPressed: _acknowledged && !_isDeleting ? _deleteAccount : null,
                      child: const Text(
                        "Delete Account",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
