import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/campaigns/passdetails.dart';

class CleanQuestScreen extends StatefulWidget {
  const CleanQuestScreen({super.key, required this.campaign});
  final Campaign campaign;

  @override
  State<CleanQuestScreen> createState() {
    return _CleanQuestScreenState();
  }
}

class _CleanQuestScreenState extends State<CleanQuestScreen> {
  late Future<DocumentSnapshot> participantsFuture;
  bool isJoined = false;
  bool isLoading = false;
  int participantsCount = 0;

  @override
  void initState() {
    super.initState();
    participantsFuture = _fetchParticipants(widget.campaign.collectionName!);
    _checkIfJoined();
  }

  Future<void> _checkIfJoined() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final DocumentSnapshot participantDoc = await FirebaseFirestore.instance
        .collection(widget.campaign.collectionName!)
        .doc('Participants')
        .get();

    final data = participantDoc.data() as Map<String, dynamic>;
    if (data['users'] != null && data['users'].contains(user.uid)) {
      setState(() {
        isJoined = true;
      });
    }
  }

  Future<void> _updateParticipants() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final DocumentReference participantRef = FirebaseFirestore.instance
        .collection(widget.campaign.collectionName!)
        .doc('Participants');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final participantSnapshot = await transaction.get(participantRef);
      if (!participantSnapshot.exists) {
        transaction.set(participantRef, {
          'number': 1,
          'users': [user.uid]
        });
      } else {
        final data = participantSnapshot.data() as Map<String, dynamic>;
        final users = List<String>.from(data['users'] ?? []);
        if (!users.contains(user.uid)) {
          users.add(user.uid);
          transaction.update(participantRef, {
            'number': FieldValue.increment(1),
            'users': users,
          });
        }
      }
    });

    setState(() {
      isJoined = true;
      isLoading = false;
      participantsFuture = _fetchParticipants(widget.campaign.collectionName!); // Refresh participants count
    });
  }

  Future<DocumentSnapshot> _fetchParticipants(String collectionName) async {
    final participantDoc = await FirebaseFirestore.instance.collection(collectionName).doc('Participants').get();
    final data = participantDoc.data() as Map<String, dynamic>;
    setState(() {
      participantsCount = data['number'] ?? 0;
    });
    return participantDoc;
  }

  String getCampaignStatus() {
    DateTime now = DateTime.now();
    if (now.isBefore(widget.campaign.startDate)) {
      Duration timeUntilStart = widget.campaign.startDate.difference(now);
      int days = timeUntilStart.inDays;
      int hours = timeUntilStart.inHours.remainder(24);
      int minutes = timeUntilStart.inMinutes.remainder(60);
      return 'Starts in ${days}d ${hours}h ${minutes}m';
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

  @override
  Widget build(BuildContext context) {
    String campaignStatus = getCampaignStatus();

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
                    onPressed: isLoading
                        ? null
                        : () {
                            if (!isJoined) {
                              _updateParticipants().then((_) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const PassDetailsScreen(),
                                  ),
                                );
                              });
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PassDetailsScreen(),
                                ),
                              );
                            }
                          },
                    icon: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          )
                        : const Icon(Icons.arrow_forward),
                    label: Text(
                      campaignStatus == 'Past'
                          ? 'Past'
                          : campaignStatus.startsWith('Starts in')
                              ? isJoined ? 'Joined' : 'Join'
                              : isJoined
                                  ? 'Joined'
                                  : 'Join',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    campaignStatus,
                    style: const TextStyle(fontSize: 16),
                  ),
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
                        buildInfoColumn('PLAYERS', '$participantsCount'),
                      ],
                    ),
                    const SizedBox(height: 8), // Adjust height as needed
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

  Column buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
