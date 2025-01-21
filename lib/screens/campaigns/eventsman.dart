import 'package:flutter/material.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/data/campaigns_data.dart';

class MangroveEventsScreen extends StatelessWidget {
  MangroveEventsScreen({super.key});

  final List<Campaign> mangroveCampaigns = [campaigns[15], campaigns[16], campaigns[17]];
  final List<String> locations = ['Coimbatore - Vadavalli', 'Ooty - Coonoor', 'Bangalore - Church Street'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mangrove Events',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/manevents.png'),
            const SizedBox(height: 16.0),
            const Text(
              'Mangrove Matters',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Participate in quests and workshops answer questions featuring about mangrove ecology and earn exciting rewards!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Quests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ...List.generate(mangroveCampaigns.length, (index) {
              return Column(
                children: [
                  _buildCampaignDetails(context, getCampaignStatus(mangroveCampaigns[index]), mangroveCampaigns[index], locations[index]),
                  const SizedBox(height: 16.0),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignDetails(
      BuildContext context, String campaignStatus, Campaign campaign, String location) {
    return ClipRRect(
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
                campaign.quest[1],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              Row(
                children: [
                  const Icon(Icons.pin_drop),
                  const SizedBox(width: 8),
                  Text(location),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
