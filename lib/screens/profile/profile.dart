import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renewa/screens/profile/bankaccdetails.dart';
import 'package:renewa/screens/profile/changepass.dart';
import 'package:renewa/screens/profile/delete_acc.dart';
import 'package:renewa/screens/profile/editprofile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userEmail = user.email;
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        setState(() {
          _userImageUrl = userSnapshot.docs.first['imageUrl'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 255, 254),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    _userImageUrl != null && _userImageUrl!.isNotEmpty
                        ? NetworkImage(_userImageUrl!)
                        : null,
                child: _userImageUrl == null || _userImageUrl!.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey.shade600,
                      )
                    : null),
            const SizedBox(height: 20),
            const ProfileButton(
                text: 'Edit Profile', screen: EditProfileScreen()),
            const ProfileButton(
                text: 'Bank Acc Details', screen: BankAccDetailsScreen()),
            const ProfileButton(
                text: 'Change Password', screen: ChangePasswordScreen()),
                const DeleteAccountButton(
                text: 'Delete Account', screen: DeleteAccountScreen()),
          ],
        ),
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key, required this.text, required this.screen});
  final String text;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 4),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(27, 142, 123, 1),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 21, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key, required this.text, required this.screen});
  final String text;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 4),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 196, 28, 28),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 21, color: Colors.white),
          ),
        ),
      ),
    );
  }
}