import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:renewa/data/campaigns_data.dart';
import 'package:renewa/feed.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/campaigns/cleanquest.dart';

class CleanCommuteScreen extends StatefulWidget {
  final Campaign campaign;

  const CleanCommuteScreen({super.key, required this.campaign});

  @override
  _CleanCommuteScreenState createState() => _CleanCommuteScreenState();
}

class _CleanCommuteScreenState extends State<CleanCommuteScreen> {
  late Future<Map<String, dynamic>> _campaignDetailsFuture;
  late Future<String?> _userSubscriptionFuture;

  @override
  void initState() {
    super.initState();
    _campaignDetailsFuture = _fetchCampaignDetails();
    _userSubscriptionFuture = _fetchUserSubscription();
  }

  Future<String?> _fetchUserSubscription() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return userDoc['subscription_type'] as String?;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchCampaignDetails() async {
    const campaignId = "Clean Commute";

    final timeQuery = await FirebaseFirestore.instance
        .collection('Campaigns')
        .where('name', isEqualTo: campaignId)
        .get();
    DateTime? startDate;
    DateTime? endDate;
    String eligibility = '';
    if (timeQuery.docs.isNotEmpty) {
      final doc = timeQuery.docs.first;
      startDate = (doc['start_date'] as Timestamp).toDate();

      endDate = (doc['end_date'] as Timestamp).toDate();
      eligibility = doc['eligibility'] as String;
    }
    startDate ??= DateTime.now();
    endDate ??= DateTime.now();

    DateTime now = DateTime.now();

    String status;
    if (now.isBefore(startDate)) {
      status = 'Upcoming';
    } else if (now.isAfter(endDate)) {
      status = 'Past';
    } else {
      Duration remainingTime = endDate.difference(now);
      int days = remainingTime.inDays;
      int hours = remainingTime.inHours.remainder(24);
      int minutes = remainingTime.inMinutes.remainder(60);
      status = 'Ongoing - Ends in ${days}d ${hours}h ${minutes}m';
    }
    // Fetch the number of participants (submissions count)
    final participantsQuery = await FirebaseFirestore.instance
        .collection('Submissions')
        .where('campaign_id', isEqualTo: campaignId)
        .where('status', isEqualTo: 'pending')
        .get();
    final creditQuery = await FirebaseFirestore.instance
        .collection('Campaigns')
        .where('name', isEqualTo: campaignId)
        .get();

    int participants = participantsQuery.docs.length;

    // Credits (can be static or dynamic)
    int credits = creditQuery.docs.first['reward_value'];

    return {
      'status': status,
      'participants': participants,
      'credits': credits,
      'startDate': startDate,
      'endDate': endDate,
      'eligibility': eligibility
    };
  }

  Color getCampaignStatusColor(
      String status, DateTime startDate, DateTime endDate) {
    DateTime now = DateTime.now();
    if (now.isBefore(startDate)) {
      return const Color.fromRGBO(254, 249, 195, 1);
    } else if (now.isAfter(endDate)) {
      return const Color.fromRGBO(217, 217, 217, 1);
    } else {
      return const Color.fromRGBO(174, 239, 188, 1);
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            const SizedBox(height: 16),
            Text(
              widget.campaign.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.campaign.description,
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
            FutureBuilder<String?>(
                future: _userSubscriptionFuture,
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return const Text('Error fetching user details');
                  } else if (!userSnapshot.hasData ||
                      userSnapshot.data == null) {
                    return const Text('No user details');
                  } else {
                    final userSubscription = userSnapshot.data!;
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _campaignDetailsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Text('Error fetching campaign details');
                        } else if (snapshot.hasData) {
                          final details = snapshot.data!;
                          final campaignStatus = details['status'];
                          final participants = details['participants'];
                          final credits = details['credits'];
                          final startDate = details['startDate'];
                          final endDate = details['endDate'];
                          final eligibility = details['eligibility'];

                          if (userSubscription == eligibility ||
                              eligibility == 'free') {
                            return _buildCampaignDetails(
                                context,
                                campaignStatus,
                                participants,
                                credits,
                                startDate,
                                endDate);
                          } else {
                            return const Text(
                              'This campaign is not available for your subscription type.',
                              style: TextStyle(fontSize: 16),
                            );
                          }
                        } else {
                          return const Text('No details found');
                        }
                      },
                    );
                  }
                }),
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

  Widget _buildCampaignDetails(BuildContext context, String campaignStatus,
      int participants, int credits, DateTime startDate, DateTime endDate) {
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
                    widget.campaign.quest[0],
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
                            campaignStatus, startDate, endDate),
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
              Text('Region - ${widget.campaign.region}'),
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
                  Text('$credits credits'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.group),
                  const SizedBox(width: 8),
                  Text('$participants participants'),
                ],
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
