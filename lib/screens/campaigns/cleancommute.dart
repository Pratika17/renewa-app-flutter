import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For date formatting
import 'package:renewa/data/campaigns_data.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/campaigns/cleanquest.dart';

class CleanCommuteScreen extends StatelessWidget {
  final Campaign campaign;

  const CleanCommuteScreen({super.key, required this.campaign});

  String getCampaignStatus(Campaign campaign) {
    DateTime now = DateTime.now();
    if (now.isBefore(campaign.startDate)) {
      return 'Upcoming';
    } else if (now.isAfter(campaign.specificEndDate)) {
      return 'Past';
    } else {
      Duration remainingTime = campaign.specificEndDate.difference(now);
      int days = remainingTime.inDays;
      int hours = remainingTime.inHours.remainder(24);
      int minutes = remainingTime.inMinutes.remainder(60);

      return 'Ongoing - Ends in ${days}d ${hours}h ${minutes}m';
    }
  }

  Color getCampaignStatusColor(Campaign campaign) {
    DateTime now = DateTime.now();
    if (now.isBefore(campaign.startDate)) {
      return const Color.fromRGBO(254, 249, 195,1);
    } else if (now.isAfter(campaign.specificEndDate)) {
      return const Color.fromRGBO(217,217,217,1);
    } else {
      return const Color.fromRGBO(174, 239, 188, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    String campaignStatus = getCampaignStatus(campaign);

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            const SizedBox(height: 16),
            Text(
              campaign.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
            _buildCampaignDetails(context, campaignStatus),
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

  Widget _buildCampaignDetails(BuildContext context, String campaignStatus) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          borderRadius: BorderRadius.circular(35.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    campaign.quest[0],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: getCampaignStatusColor(
                          campaign,
                        ),
                        foregroundColor: Colors.black),
                    child: Text(
                      campaignStatus.contains('Ongoing')
                          ? 'Ongoing'
                          : campaignStatus.contains('Upcoming')
                              ? 'Upcoming'
                              : 'Past',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Region - ${campaign.region}'),
              const SizedBox(height: 8),
              const Text(
                  'Unlock rewards with every journey! Travel passes that lead to exciting perks await.'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer),
                  const SizedBox(width: 8),
                  Text(campaignStatus),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.credit_card),
                  const SizedBox(width: 8),
                  Text('${campaign.credits} credits'),
                ],
              ),
              const SizedBox(height: 8),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(campaign.collectionName!)
                    .doc('Participants')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Row(
                      children: [
                        Icon(Icons.group),
                        SizedBox(width: 8),
                        Text('Loading participants...'),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return const Row(
                      children: [
                        Icon(Icons.group),
                        SizedBox(width: 8),
                        Text('Error loading participants'),
                      ],
                    );
                  } else if (snapshot.hasData && snapshot.data!.exists) {
                    int participants = snapshot.data!.get('number') as int;
                    return Row(
                      children: [
                        const Icon(Icons.group),
                        const SizedBox(width: 8),
                        Text('$participants participants'),
                      ],
                    );
                  } else {
                    return const Row(
                      children: [
                        Icon(Icons.group),
                        SizedBox(width: 8),
                        Text('No participants data available'),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(width: 2),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              CleanQuestScreen(campaign: campaigns[18]),
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
}
