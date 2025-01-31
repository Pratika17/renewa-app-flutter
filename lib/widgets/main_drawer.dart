import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renewa/screens/newFeatures/credit_points.dart';
import 'package:renewa/screens/newFeatures/premium_screen.dart';
import 'package:renewa/screens/profile/profile.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final authenticatedUser = FirebaseAuth.instance.currentUser!;
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
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(authenticatedUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _subscriptionType = userDoc.data()?['subscription_type'];
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

  Future<String> _getUserName() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(authenticatedUser.uid)
        .get();
    return userDoc.data()?['user_name'] ?? 'Profile';
  }

  Future<String?> _getUserImageUrl() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(authenticatedUser.uid)
        .get();
    return userDoc.data()?['imageUrl'];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                FutureBuilder<String?>(
                  future: _getUserImageUrl(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 0, 0, 0),
                        radius: 27,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 0, 0, 0),
                        radius: 27,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                      );
                    } else {
                      return CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        radius: 27,
                        backgroundImage: NetworkImage(snapshot.data!),
                      );
                    }
                  },
                ),
                const SizedBox(width: 18),
                FutureBuilder<String>(
                  future: _getUserName(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        'Loading...',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error!',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      );
                    } else {
                      return Text(
                        snapshot.data ?? 'Profile',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Profile',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.money,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Credit Points',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const CreditPointsScreen()),
              );
            },
          ),
          if (!_isLoading)
            ListTile(
              leading: Icon(
                Icons.stars,
                size: 26,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                _subscriptionType == 'free' ? 'Get Premium' : 'View Benefits',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                    ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const PremiumScreen()),
                );
              },
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
