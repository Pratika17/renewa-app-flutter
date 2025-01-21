import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:renewa/screens/profile/coupons_junior.dart';
import 'package:renewa/screens/profile/coupons_senior.dart';
import 'package:renewa/screens/profile/profile.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key});

  final authenticatedUser = FirebaseAuth.instance.currentUser!;

  Future<String> _getUserName() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(authenticatedUser.uid)
        .get();
    return userDoc.data()?['username'] ?? 'Profile';
  }

  Future<void> _handleCouponsNavigation(BuildContext context) async {
    print("Coupons navigation started");
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authenticatedUser.uid)
          .get();

      if (!userDoc.exists || !userDoc.data()!.containsKey('dob')) {
        // No DOB found
        print("DOB not found");
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content:const Text('Please verify your age to get coupons'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
        return;
      }

      String dobStr = userDoc.data()!['dob'];
      // Parse date from "YYYY/MM/DD" format
      List<String> dateParts = dobStr.split('/');
      DateTime dob = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      DateTime today = DateTime.now();

      int age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      print("User age: $age");

      if (age >= 50) {
        print("Navigating to CouponsSeniorScreen");
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => CouponsSeniorScreen()),
        );
      } else {
        print("Navigating to CouponsJuniorScreen");
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const CouponsJuniorScreen()),
        );
      }
    } catch (e) {
      print("Error in coupons navigation: $e");
    }
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
                const CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 0, 0, 0),
                  radius: 27,
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
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
              Icons.health_and_safety,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Coupons',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              _handleCouponsNavigation(context);
            },
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
