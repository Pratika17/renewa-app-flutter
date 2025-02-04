import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:renewa/data/campaigns_data.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/campaigns/ccquest.dart';

class CoverCroppingScreen extends StatefulWidget {
  const CoverCroppingScreen({super.key});

  @override
  _CoverCroppingScreenState createState() => _CoverCroppingScreenState();
}

class _CoverCroppingScreenState extends State<CoverCroppingScreen> {
  late Future<Map<String, dynamic>> _campaign1DetailsFuture;
  late Future<Map<String, dynamic>> _campaign2DetailsFuture;
  late Future<Map<String, dynamic>> _campaign3DetailsFuture;
  late Future<List<Map<String, dynamic>>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _quizzesFuture = _fetchQuizzes();
    _campaign1DetailsFuture = _fetchCampaignDetails("Cover Cropping");
    _campaign2DetailsFuture = _fetchCampaignDetails("Discovering");
    _campaign3DetailsFuture = _fetchCampaignDetails("Cover Cropping");
  }

  Future<List<Map<String, dynamic>>> _fetchQuizzes() async {
    List<Map<String, dynamic>> quizzesData = [];
    final quizzesQuery =
        await FirebaseFirestore.instance.collection('Quizzes').get();

    for (final quizDoc in quizzesQuery.docs) {
      final questionsQuery =
          await quizDoc.reference.collection('questions').get();

      List<Map<String, dynamic>> questions = [];
      for (final questionDoc in questionsQuery.docs) {
        final optionsQuery =
            await questionDoc.reference.collection('options').get();
        List<Map<String, dynamic>> options = [];

        for (final optionDoc in optionsQuery.docs) {
          options.add(optionDoc.data());
        }
        questions.add({...questionDoc.data(), 'options': options});
      }
      quizzesData.add({...quizDoc.data(), 'questions': questions});
    }
    return quizzesData;
  }

  Future<Map<String, dynamic>> _fetchCampaignDetails(String campaignId) async {
    final timeQuery = await FirebaseFirestore.instance
        .collection('Campaigns')
        .where('name', isEqualTo: campaignId)
        .get();
    DateTime? startDate;
    DateTime? endDate;
    if (timeQuery.docs.isNotEmpty) {
      final doc = timeQuery.docs.first;
      startDate = (doc['start_date'] as Timestamp).toDate();
      endDate = (doc['end_date'] as Timestamp).toDate();
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
        title: const Text('Cover Cropping',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            top: 16.0, bottom: 16.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/cc.png'),
            const SizedBox(height: 16.0),
            const Text(
              'Cover Cropping',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Participate in quests and workshops\nanswer questions featuring about cover cropping and earn exciting rewards!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Description :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            buildSectionTitle(context, 'What is cover cropping?'),
            buildSectionContent(
                'Cover cropping is a sustainable agricultural practice wherein specific crops are grown primarily to benefit the soil rather than for harvesting. These crops, known as cover crops or green manure, are planted during periods when the main cash crop is not growing. The main purpose of cover cropping is to improve soil health, fertility, and structure, as well as to suppress weeds, prevent erosion, and enhance water retention.'),
            const SizedBox(height: 8.0),
            buildSectionContent(
                'Cover crops can vary depending on the region and specific farming goals, but common examples include legumes like clover and vetch, grasses such as rye and oats, and brassicas like radishes and mustard. Legumes are particularly valuable because they can fix nitrogen from the atmosphere into the soil, thus enriching it with this essential nutrient. When the cover crop is incorporated into the soil, either by plowing or through natural decomposition, it adds organic matter, nutrients, and beneficial microorganisms, promoting overall soil health and productivity.'),
            const SizedBox(height: 16.0),
            buildSectionTitle(
                context, 'Why Cover Cropping is important to us?'),
            buildSectionContent(
                'Cover cropping offers numerous benefits to both agricultural sustainability and broader societal well being.'),
            buildBulletPoint(context, 'Food Security:'),
            buildBulletContent(
                'By improving soil health and fertility, cover cropping enhances the productivity and resilience of agricultural systems. This leads to increased food production, contributing to food security for Indian citizens and reducing dependence on food imports.'),
            buildBulletPoint(context, 'Environmental Conservation:'),
            buildBulletContent(
                'Cover cropping helps conserve soil and water resources by reducing erosion, improving water retention, and enhancing soil structure. This not only sustains agricultural productivity but also protects the environment, ensuring a healthier and more sustainable ecosystem for present and future generations.'),
            buildBulletPoint(context, 'Water Management:'),
            buildBulletContent(
                'In a country where water scarcity is a significant concern, cover cropping plays a crucial role in water management. Cover crops help to retain soil moisture, reduce evaporation, and enhance groundwater recharge, thereby improving water-use efficiency and supporting agricultural productivity, especially in regions prone to drought.'),
            buildBulletPoint(context, 'Biodiversity Conservation:'),
            buildBulletContent(
                'Cover cropping promotes biodiversity by providing habitat and food sources for beneficial insects, pollinators, and soil organisms. This contributes to the conservation of biodiversity, which is essential for ecosystem health, agricultural productivity, and the overall resilience of natural systems.'),
            const SizedBox(height: 16.0),
            const Text(
              'Quests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _quizzesFuture,
              builder: (context, quizSnapshot) {
                if (quizSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (quizSnapshot.hasError) {
                  return const Text('Error fetching quiz details');
                } else if (!quizSnapshot.hasData) {
                  return const Text('No quizzes found');
                } else {
                  final quizzes = quizSnapshot.data!;

                  return Column(
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: _campaign1DetailsFuture,
                        builder: (context, snapshot) {
                          return _buildCampaignDetails(
                            context,
                            snapshot,
                            campaigns[4],
                            quizzes[0]['questions'],
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _campaign2DetailsFuture,
                        builder: (context, snapshot) {
                          return _buildCampaignDetails(
                            context,
                            snapshot,
                            campaigns[5],
                            quizzes[1]['questions'],
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _campaign3DetailsFuture,
                        builder: (context, snapshot) {
                          return _buildCampaignDetails(
                            context,
                            snapshot,
                            campaigns[6],
                            quizzes[2]['questions'],
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget buildBulletPoint(BuildContext context, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(Icons.check, size: 16),
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget buildBulletContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
  Widget _buildCampaignDetails(
      BuildContext context,
      AsyncSnapshot<Map<String, dynamic>> snapshot,
      Campaign campaign,
      List<Map<String, dynamic>> questions) { // questions is already List<Map<String,dynamic>>
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return const Text('Error fetching campaign details');
    } else if (!snapshot.hasData) {
      return const Text('No details found');
    }

    final details = snapshot.data!;
    final campaignStatus = details['status'];
    final participants = details['participants'];
    final credits = details['credits'];
    final startDate = details['startDate'];
    final endDate = details['endDate'];

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
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: getCampaignStatusColor(
                          campaignStatus,
                          startDate,
                          endDate,
                        ),
                        foregroundColor: Colors.black),
                    label: Text(
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
                          builder: (context) => CoverCropQuestScreen(
                            campaign: campaign,
                            questions: questions, // Pass questions directly - it's already List<Map<String, dynamic>>
                            options: questions
                                .map<List<String>>((q) => (q['options'] as List<dynamic>)
                                    .map((o) => o['text'] as String)
                                    .toList())
                                .toList(),
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
}