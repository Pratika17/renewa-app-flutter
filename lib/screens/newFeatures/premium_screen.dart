import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String? _subscriptionType;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchSubscriptionType();
  }

  Future<void> _fetchSubscriptionType() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      final userEmail = user.email;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_email', isEqualTo: userEmail)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first;

        setState(() {
          _subscriptionType = userData['subscription_type'];
        });
      }
    } catch (e) {
      print("Error fetching subscription type: $e");
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
        title: Text(
            _subscriptionType == 'free' ? 'Get Premium' : 'Premium Features',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _subscriptionType == 'free'
                          ? 'Unlock Exclusive Features with Premium!'
                          : 'With Premium, you get access to:',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (_subscriptionType == 'premium')
                      const Text(
                        'With Premium, you get access to:',
                        textAlign: TextAlign.center,
                      ),
                    if (_subscriptionType == 'premium')
                      const SizedBox(height: 10),
                    if (_subscriptionType == 'premium')
                      const Text(
                        '- Ad-free experience',
                        textAlign: TextAlign.center,
                      ),
                    if (_subscriptionType == 'premium')
                      const SizedBox(height: 8),
                    if (_subscriptionType == 'premium')
                      const Text(
                        '- Exclusive quests and rewards',
                        textAlign: TextAlign.center,
                      ),
                    if (_subscriptionType == 'premium')
                      const SizedBox(height: 8),
                    if (_subscriptionType == 'premium')
                      const Text(
                        '- Premium support',
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 30),
                    if (_subscriptionType == 'free')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Implement premium purchase/ logic here
                        },
                        child: const Text('Get Premium'),
                      ),
                    if (_subscriptionType == 'premium')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Implement view benefits here
                        },
                        child: const Text('View Benefits'),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
