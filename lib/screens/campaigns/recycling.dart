import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renewa/data/campaigns_data.dart';
import 'package:renewa/feed.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/newFeatures/citizens.dart';
import 'package:renewa/screens/newFeatures/collection_workers.dart';
import 'package:renewa/screens/newFeatures/dealers.dart';

class RecyclingScreen extends StatefulWidget {
  final Campaign campaign;

  const RecyclingScreen({super.key, required this.campaign});

  @override
  State<RecyclingScreen> createState() => _RecyclingScreenState();
}

class _RecyclingScreenState extends State<RecyclingScreen> {
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
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
          _userRole = userData['recycle_role'];
        });
      }
    } catch (e) {
      print("Error: $e");
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
          widget.campaign.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedScreen(),
                ),
              );
            },
            child: const Text(
              'Feed',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Recycling',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Turn the trashes into rewards and join\n the green revolution today! Click to get \nstarted',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_buildRoleButtons(context)]),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
            ),
          ),
          height: 300,
          width: 300,
          child: Image.asset(widget.campaign.imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildRoleButtons(BuildContext context) {
    if (_userRole == null) {
      return const SizedBox();
    }
    if (_userRole == 'Citizen') {
      return ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CitizenScreen(
                  campaign: campaigns[13],
                  collectionName: campaigns[13].collectionName ?? 'Recycling',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 175, 226, 130),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: const Text("Citizen",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)));
    } else if (_userRole == 'Collection Worker') {
      return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CollectionWorkersScreen(
                campaign: campaigns[13],
                collectionName: campaigns[13].collectionName ?? 'Recycling',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 175, 226, 130),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: const Text(
          "Collection Worker",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
    } else if (_userRole == 'Dealer') {
      return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DealersScreen(
                campaign: campaigns[13],
                collectionName: campaigns[13].collectionName ?? 'Recycling',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 175, 226, 130),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: const Text(
          "Dealer",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
