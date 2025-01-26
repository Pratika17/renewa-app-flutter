import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renewa/data/campaigns_data.dart';
import 'package:renewa/feed.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/campaign_quests.dart';
import 'package:renewa/screens/newFeatures/citizens.dart';
import 'package:renewa/screens/newFeatures/collection_workers.dart';

class RecyclingScreen extends StatelessWidget {
  final Campaign campaign;

  const RecyclingScreen({super.key, required this.campaign});

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
          campaign.title,
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
                'Turn your recyclables to rewards and join\n the green revolution today! Click to get \nstarted',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            _buildRoleButtons(context),
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
          child: Image.asset(campaign.imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildRoleButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
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
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: const Text("Citizen",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black))),
        const SizedBox(height: 16),
        ElevatedButton(
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
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: const Text(
              "Collection Worker",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )),
        const SizedBox(height: 16),
        ElevatedButton(
            onPressed: () {
              _navigateToQuestScreen(context, 'Dealer');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 175, 226, 130),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: const Text(
              "Dealer",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )),
      ],
    );
  }

  Future<void> _navigateToQuestScreen(BuildContext context, String role) async {
    // Check if the user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not logged in, show a message and return
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please log in to view quests.'),
          duration: Duration(seconds: 3)));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CampaignQuestScreen(
          campaign: campaign,
          collectionName: campaign.collectionName!,
        ),
      ),
    );
  }
}
