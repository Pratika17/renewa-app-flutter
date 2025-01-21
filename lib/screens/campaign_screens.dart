// lib/screens/campaign_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/campaign_quests.dart';

class CampaignDetailScreen extends StatelessWidget {
  const CampaignDetailScreen({super.key, required this.campaign});
  final Campaign campaign;


  @override
  Widget build(BuildContext context) {
    Duration remainingTime = campaign.specificEndDate.difference(DateTime.now());
    String formattedRemainingTime = '${remainingTime.inDays} days ${remainingTime.inHours.remainder(24)} hrs ${remainingTime.inMinutes.remainder(60)} mins';

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
                        color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
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
                    borderRadius: BorderRadius.circular(35.0), // Apply border radius here as well
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.quest[0],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Plant saplings and receive amazing rewards!'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer),
                            const SizedBox(width: 8),
                            Text('Ends in $formattedRemainingTime'),
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
                        Row(
                          children: [
                            const Icon(Icons.group),
                            const SizedBox(width: 8),
                            Text('${campaign.participants} participants'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(width: 2,),
                            const Spacer(),
                            ElevatedButton.icon(
                            style:ElevatedButton.styleFrom(backgroundColor: Colors.black,foregroundColor: Colors.white),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CampaignQuestScreen(campaign: campaign,collectionName: campaign.collectionName!),
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
}
