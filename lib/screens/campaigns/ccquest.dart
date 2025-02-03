import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/campaign_upload.dart';
import 'package:renewa/screens/campaigns/quizes1.dart';

class CoverCropQuestScreen extends StatefulWidget {
  const CoverCropQuestScreen({
    super.key,
    required this.campaign,
    required this.questions,
    required this.options,
    required this.collectionName,
  });

  final Campaign campaign;
  final List<String> questions;
  final List<List<String>> options;
  final String collectionName;

  @override
  State<CoverCropQuestScreen> createState() => _CoverCropQuestScreenState();
}

class _CoverCropQuestScreenState extends State<CoverCropQuestScreen> {
  late bool isJoining;
  User? currentUser;

  // Variables to store fetched campaign details
  DateTime? campaignStartDate;
  DateTime? campaignEndDate;
  int campaignCredits = 0;

  @override
  void initState() {
    super.initState();
    isJoining = false;
    fetchCurrentUser();
    fetchCampaignDetails(); // Fetch campaign details
  }

  Future<void> fetchCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<int> fetchParticipantsCount() async {
    final participantsQuery = await FirebaseFirestore.instance
        .collection('Submissions')
        .where('campaign_id', isEqualTo: widget.campaign.title)
        .where('status', isEqualTo: 'pending')
        .get();
    return participantsQuery.docs.length;
  }

  Future<void> fetchCampaignDetails() async {
    final campaignQuery = await FirebaseFirestore.instance
        .collection('Campaigns')
        .where('name', isEqualTo: widget.campaign.quest[0])
        .get();

    if (campaignQuery.docs.isNotEmpty) {
      final doc = campaignQuery.docs.first;
      setState(() {
        campaignStartDate = (doc['start_date'] as Timestamp).toDate();
        campaignEndDate = (doc['end_date'] as Timestamp).toDate();
        campaignCredits = doc['reward_value'];
      });
    }
  }

  String getCampaignStatus() {
    DateTime now = DateTime.now();
    if (campaignStartDate == null || campaignEndDate == null) {
      return 'Loading...'; // Or some default status
    }
    if (now.isBefore(campaignStartDate!)) {
      Duration timeUntilStart = campaignStartDate!.difference(now);
      int days = timeUntilStart.inDays;
      int hours = timeUntilStart.inHours.remainder(24);
      int minutes = timeUntilStart.inMinutes.remainder(60);
      return 'Upcoming - Starts in ${days}d ${hours}h ${minutes}m';
    } else if (now.isAfter(campaignEndDate!)) {
      return 'Past';
    } else {
      Duration remainingTime = campaignEndDate!.difference(now);
      int days = remainingTime.inDays;
      int hours = remainingTime.inHours.remainder(24);
      int minutes = remainingTime.inMinutes.remainder(60);
      return 'Ongoing - Ends in ${days}d ${hours}h ${minutes}m';
    }
  }

  Future<void> joinQuest() async {
    if (currentUser == null || isJoining) return;

    setState(() {
      isJoining = true;
    });

    try {
      // No need for participants document reference. User will have a submission document
      // Navigate to the next screen
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CampaignUploadScreen(campaign: widget.campaign),
      ));
    } catch (e) {
      // Handle errors if needed
    } finally {
      setState(() {
        isJoining = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String campaignStatus = getCampaignStatus();
    bool isCampaignOngoing = campaignStatus.startsWith('Ongoing');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Quest',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quest - ${widget.campaign.quest[0]}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isJoining
                        ? null
                        : isCampaignOngoing
                            ? joinQuest
                            : () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                    questions: widget.questions,
                                    options: widget.options,
                                    campaignTitle: widget.campaign.title,
                                    questTitle: widget.campaign.quest[0],
                                  ),
                                ));
                              },
                    icon: isJoining
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.arrow_forward),
                    label: Text(isCampaignOngoing
                        ? 'Join Quest'
                        : (campaignStatus.startsWith('Upcoming')
                            ? 'Upcoming'
                            : 'Past')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(campaignStatus, style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('STARTS',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(
                                campaignStartDate != null
                                    ? DateFormat('MMM dd, yyyy')
                                        .format(campaignStartDate!)
                                    : 'Loading...',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ENDS',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(
                                campaignEndDate != null
                                    ? DateFormat('MMM dd, yyyy')
                                        .format(campaignEndDate!)
                                    : 'Loading...',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CREDIT',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('$campaignCredits',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        FutureBuilder<int>(
                          future: fetchParticipantsCount(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PLAYERS',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  Text('Loading...',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PLAYERS',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  Text('Error', style: TextStyle(fontSize: 12)),
                                ],
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PLAYERS',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  Text('${snapshot.data}',
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black),
              const Text(
                'Outcomes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.campaign.outcomes,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              const Divider(color: Colors.black),
              const Text(
                'Introduction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.campaign.introduction,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              const Divider(color: Colors.black),
              const Text(
                'Quest Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.campaign.deliverables,
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
