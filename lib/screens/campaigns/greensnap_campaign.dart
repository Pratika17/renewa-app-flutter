import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure you have this imported
import 'package:renewa/feed.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/campaign_quests.dart';
import 'package:renewa/screens/newFeatures/plantpurchase.dart';

class GreenSnapCampaignScreen extends StatelessWidget {
  const GreenSnapCampaignScreen({super.key, required this.campaign});
  final Campaign campaign;

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
        title: Text(campaign.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Button background color
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30), // Optional: for rounded corners
              ),
            ),
            onPressed: () {
              // Add navigation or logic for the Feed button here
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const FeedScreen(), // Replace with your Feed screen
                ),
              );
            },
            child: const Text(
              'Feed',
              style: TextStyle(
                color: Colors.white, // Text color
                fontWeight: FontWeight.bold,
                fontSize: 16, // Font size
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 74, 116, 66),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlantPurchaseScreen(),
                        ),
                      );
                    },
                    label: const Text('Purchase plants'),
                    icon: const Icon(Icons.shopping_cart),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                campaign.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Featured Campaigns',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, dynamic>>(
                future: _fetchCampaignDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error fetching campaign details');
                  } else if (snapshot.hasData) {
                    final details = snapshot.data!;
                    final campaignStatus = details['status'];
                    final participants = details['participants'];
                    final credits = details['credits'];

                    return _buildCampaignDetails(
                      context,
                      campaignStatus,
                      participants,
                      credits,
                    );
                  } else {
                    return const Text('No details found');
                  }
                },
              ),
            ],
          ),
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

  Widget _buildCampaignDetails(
      BuildContext context, String status, int participants, int credits) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          borderRadius:
              BorderRadius.circular(35.0), // Apply border radius here as well
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Campaign Status:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(status),
                ],
              ),
              const SizedBox(height: 8),
              Text('Region - ${campaign.region}'),
              const SizedBox(height: 8),
              const Text('Plant saplings and receive amazing rewards!'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.group),
                  const SizedBox(width: 8),
                  Text('$participants participants'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.credit_card),
                  const SizedBox(width: 8),
                  Text('$credits credits'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Adjust spacing
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CampaignQuestScreen(
                            campaign: campaign,
                            collectionName: campaign.collectionName!,
                          ),
                        ),
                      );
                    },
                    label: const Text('View Quest'),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchCampaignDetails() async {
    final timeQuery = await FirebaseFirestore.instance
        .collection('Campaigns')
        .where('name', isEqualTo: "GreenSnap")
        .get();
    DateTime? startDate;
    DateTime? endDate;
    DateTime now = DateTime.now();
    if (timeQuery.docs.isNotEmpty) {
      final doc = timeQuery.docs.first;
      startDate = (doc['start_date'] as Timestamp).toDate();

      endDate = (doc['end_date'] as Timestamp).toDate();
    }

    startDate ??= DateTime.now();
    endDate ??= DateTime.now();
    print(startDate);

    // Calculate campaign status
    String status;
    if (now.isBefore(startDate)) {
      status = 'Upcoming';
    } else if (now.isAfter(endDate)) {
      status = 'Past';
    } else {
      status = 'Ongoing';
    }

    // Fetch the number of participants (submissions count)
    final participantsQuery = await FirebaseFirestore.instance
        .collection('submissions')
        .where('campaign_id', isEqualTo: campaign.id)
        .where('created_at', isGreaterThanOrEqualTo: campaign.startDate)
        .where('created_at', isLessThanOrEqualTo: campaign.specificEndDate)
        .get();

    int participants = participantsQuery.docs.length;

    // Credits (can be static or dynamic)
    int credits = campaign.credits;

    return {
      'status': status,
      'participants': participants,
      'credits': credits,
    };
  }
}
