import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() {
    return _ChangePasswordScreenState();
  }
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Close the keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text,
      );

      // Reauthenticate the user
      await user.reauthenticateWithCredential(cred);

      // Update the password
      await user.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully')));

      // Pop the screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update password. Please try again.')));
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
                padding: EdgeInsets.only(
                  left: 40,
                  right: 40.0,
                  top: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: _oldPasswordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: false,
                        hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        hintText: "Old Password",
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: false,
                        hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        hintText: "New Password",
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 70),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _changePassword,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 16, bottom: 16, right: 24, left: 24),
                            maximumSize: const Size(200, 50),
                            backgroundColor: const Color.fromRGBO(27, 142, 123, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
