import 'package:flutter/material.dart';
import 'package:renewa/screens/profile/bankaccdetails.dart';
import 'package:renewa/screens/profile/changepass.dart';
import 'package:renewa/screens/profile/editprofile.dart';
import 'package:renewa/screens/profile/questrecords.dart';
import 'package:renewa/screens/profile/rewards.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            const ProfileButton(text: 'Edit Profile', screen:EditProfileScreen()),
            ProfileButton(text: 'Rewards Earned', screen: RewardsScreen()),
            const ProfileButton(text: 'Bank Acc Details', screen: BankAccDetailsScreen()),
            const ProfileButton(text: 'Change Password', screen: ChangePasswordScreen()),
            ProfileButton(text: 'Quest Records', screen: QuestRecordsScreen()),
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