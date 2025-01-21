import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renewa/models/campaign_model.dart';
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
  State<CoverCropQuestScreen> createState() {
    return _CoverCropQuestScreenState();
  }
}

class _CoverCropQuestScreenState extends State<CoverCropQuestScreen> {
  late bool isJoined;
  late bool isJoining;
  User? currentUser;
  int participantsCount = 0;

  @override
  void initState() {
    super.initState();
    isJoined = false;
    isJoining = false;
    fetchCurrentUser();
    fetchParticipantsCount();
  }

  Future<void> fetchCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await checkIfJoined();
    }
  }

  Future<void> checkIfJoined() async {
    final userDocRef = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc('Participants')
        .collection('Users')
        .doc(currentUser!.uid);

    DocumentSnapshot userSnapshot = await userDocRef.get();
    if (userSnapshot.exists) {
      setState(() {
        isJoined = true;
      });
    }
  }

  Future<void> fetchParticipantsCount() async {
    final participantsDocRef = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc('Participants');

    DocumentSnapshot snapshot = await participantsDocRef.get();
    if (snapshot.exists) {
      setState(() {
        participantsCount = snapshot['number'];
      });
    }
  }

  String getCampaignStatus() {
    DateTime now = DateTime.now();
    if (now.isBefore(widget.campaign.startDate)) {
      Duration timeUntilStart = widget.campaign.startDate.difference(now);
      int days = timeUntilStart.inDays;
      int hours = timeUntilStart.inHours.remainder(24);
      int minutes = timeUntilStart.inMinutes.remainder(60);
      return 'Upcoming - Starts in ${days}d ${hours}h ${minutes}m';
    } else if (now.isAfter(widget.campaign.specificEndDate)) {
      return 'Past';
    } else {
      Duration remainingTime = widget.campaign.specificEndDate.difference(now);
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
      final participantsDocRef = FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc('Participants');

      final userDocRef = participantsDocRef
          .collection('Users')
          .doc(currentUser!.uid);

      DocumentSnapshot userSnapshot = await userDocRef.get();

      if (!userSnapshot.exists) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(participantsDocRef);

          if (!snapshot.exists) {
            throw Exception("Campaign does not exist!");
          }

          int currentParticipants = snapshot['number'];
          transaction.update(participantsDocRef, {'number': currentParticipants + 1});
          transaction.set(userDocRef, {'joined': true});

          setState(() {
            participantsCount = currentParticipants + 1;
            isJoined = true;
          });
        });
      }
    } catch (e) {
      // Handle errors if needed
    } finally {
      setState(() {
        isJoining = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            questions: widget.questions,
            options: widget.options,
            campaignTitle: widget.campaign.title,
            questTitle: widget.campaign.quest[0],
          ),
        ),
      );
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
        title: const Text('Quest', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  Text('Quest - ${widget.campaign.quest[0]}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => QuizScreen(
                                      questions: widget.questions,
                                      options: widget.options,
                                      campaignTitle: widget.campaign.title,
                                      questTitle: widget.campaign.quest[0],
                                    ),
                                  ),
                                );
                              },
                    icon: isJoining ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.arrow_forward),
                    label: Text(isCampaignOngoing ? (isJoined ? 'Joined' : 'Join Quest') : (campaignStatus.startsWith('Upcoming') ? 'Upcoming' : 'Past')),
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
                            const Text('STARTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(DateFormat('MMM dd, yyyy').format(widget.campaign.startDate), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ENDS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(DateFormat('MMM dd, yyyy').format(widget.campaign.specificEndDate), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CREDITS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('1500', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CREDIT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('${widget.campaign.credits}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PLAYERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('$participantsCount', style: const TextStyle(fontSize: 12)),
                          ],
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
              Text(widget.campaign.outcomes, style: const TextStyle(fontSize: 16)),
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
              Text(widget.campaign.introduction, style: const TextStyle(fontSize: 16)),
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
              Text(widget.campaign.deliverables, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
