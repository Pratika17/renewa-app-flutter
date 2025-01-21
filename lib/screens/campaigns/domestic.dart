import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/campaign_quests.dart';

class DomesticScreen extends StatelessWidget {
  const DomesticScreen({super.key, required this.campaign});
  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    Color buttonColor;
    String buttonText;
    String formattedRemainingTime;

    if (now.isBefore(campaign.startDate)) {
      buttonColor = const Color.fromRGBO(254, 249, 195, 1);
      buttonText = 'Upcoming';
      Duration timeToStart = campaign.startDate.difference(now);
      formattedRemainingTime =
          'Starts in ${timeToStart.inDays}d ${timeToStart.inHours.remainder(24)}h ${timeToStart.inMinutes.remainder(60)}m';
    } else if (now.isAfter(campaign.specificEndDate)) {
      buttonColor = const Color.fromRGBO(217, 217, 217, 1);
      buttonText = 'Past';
      formattedRemainingTime = 'Ended';
    } else {
      Duration remainingTime = campaign.specificEndDate.difference(now);
      formattedRemainingTime =
          'Ends in ${remainingTime.inDays}d ${remainingTime.inHours.remainder(24)}h ${remainingTime.inMinutes.remainder(60)}m';
      buttonColor = const Color.fromRGBO(174, 239, 188, 1);
      buttonText = 'Ongoing';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(campaign.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                      ),
                    ),
                    height: 300,
                    width: 300,
                    child: Image.asset(campaign.imagePath, fit: BoxFit.cover),
                  ),
                ),
              ),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(35.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    borderRadius: BorderRadius.circular(
                        35.0), // Apply border radius here as well
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
                                  backgroundColor: buttonColor,
                                  foregroundColor: Colors.black),
                              child: Text(
                                buttonText,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Region - ${campaign.region}'),
                        const SizedBox(height: 8),
                        const Text(
                            'Conserve water and receive amazing rewards!'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer),
                            const SizedBox(width: 8),
                            Text(formattedRemainingTime),
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
                        FutureBuilder<DocumentSnapshot>(
                          future:
                              _fetchParticipants(), // Call the function to fetch participants
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Row(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 8),
                                  Text('Loading participants...'),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return const Text('Error fetching participants');
                            } else if (snapshot.hasData) {
                              final data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final participants = data['number'] ?? 0;
                              return Row(
                                children: [
                                  const Icon(Icons.group),
                                  const SizedBox(width: 8),
                                  Text('$participants participants'),
                                ],
                              );
                            } else {
                              return const Text('No participants found');
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
                                    builder: (context) => CampaignQuestScreen(
                                        campaign: campaign,
                                        collectionName:
                                            campaign.collectionName!),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DocumentSnapshot> _fetchParticipants() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is signed in.');
    }
    return await FirebaseFirestore.instance
        .collection('Domestic Aqua Savers')
        .doc('Participants')
        .get();
  }
}
