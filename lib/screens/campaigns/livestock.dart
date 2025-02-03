import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/data/campaigns_data.dart';
import 'package:renewa/screens/campaigns/questlivestock.dart';

class LiveStockScreen extends StatefulWidget {
  LiveStockScreen({super.key});

  @override
  _LiveStockScreenState createState() => _LiveStockScreenState();
}

class _LiveStockScreenState extends State<LiveStockScreen> {
  late Future<Map<String, dynamic>> _campaign1DetailsFuture;
  late Future<Map<String, dynamic>> _campaign2DetailsFuture;
  late Future<Map<String, dynamic>> _campaign3DetailsFuture;

  final List<String> questions1 = [
    'What is livestock grazing, and where is it typically practiced?',
    'What are the benefits of livestock grazing?',
    'What are the challenges of livestock grazing?',
  ];

  final List<List<String>> options1 = [
    [
      'a. Livestock grazing is the practice of feeding animals in enclosed barns.',
      'b. Livestock grazing is the practice of feeding animals on pasturelands.',
      'c. Livestock grazing is the practice of feeding animals in urban areas.',
      'd. Livestock grazing is the practice of feeding animals on rooftops.'
    ],
    [
      'a. Livestock grazing helps in maintaining soil fertility.',
      'b. Livestock grazing helps in increasing greenhouse gas emissions.',
      'c. Livestock grazing helps in causing soil erosion.',
      'd. Livestock grazing helps in reducing water retention in soil.'
    ],
    [
      'a. Livestock grazing can lead to overgrazing and land degradation.',
      'b. Livestock grazing can lead to increased urban development.',
      'c. Livestock grazing can lead to a decrease in animal populations.',
      'd. Livestock grazing can lead to water pollution in rivers.'
    ]
  ];

  final List<String> questions2 = [
    'How can sustainable livestock grazing be achieved?',
    'What is rotational grazing?',
    'Which of the following is a method to prevent overgrazing?',
  ];

  final List<List<String>> options2 = [
    [
      'a. By continuously grazing the same area without rest.',
      'b. By rotating livestock between different pastures.',
      'c. By increasing the number of livestock per hectare.',
      'd. By grazing livestock only during the rainy season.'
    ],
    [
      'a. Keeping livestock in a fixed pasture all year round.',
      'b. Moving livestock between different pastures to prevent overgrazing.',
      'c. Grazing livestock on different crops in a rotation.',
      'd. Feeding livestock only during the winter season.'
    ],
    [
      'a. Increasing the number of livestock.',
      'b. Reducing the grazing period and allowing recovery time for pastures.',
      'c. Grazing livestock in the same area all year round.',
      'd. Allowing livestock to graze on crops meant for human consumption.'
    ]
  ];

  final List<String> questions3 = [
    'What role does livestock grazing play in biodiversity?',
    'Which nutrient is commonly found in animal manure and is essential for soil fertility?',
    'What type of animals are commonly used for draught power in many regions?',
  ];

  final List<List<String>> options3 = [
    [
      'a. It decreases plant diversity by allowing dominant species to take over.',
      'b. It helps maintain plant diversity by preventing any one species from dominating.',
      'c. It has no impact on plant diversity.',
      'd. It reduces biodiversity by promoting invasive species.'
    ],
    ['a. Carbon', 'b. Nitrogen', 'c. Oxygen', 'd. Hydrogen'],
    ['a. Pigs', 'b. Chickens', 'c. Oxen', 'd. Sheep']
  ];

  @override
  void initState() {
    super.initState();
    _campaign1DetailsFuture = _fetchCampaignDetails("Livestock Grazing");
    _campaign2DetailsFuture = _fetchCampaignDetails("Livestock Grazing");
    _campaign3DetailsFuture = _fetchCampaignDetails("Livestock Grazing");
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
        title: const Text('Livestock Grazing',
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
            Image.asset('assets/images/livestock.png'),
            const SizedBox(height: 16.0),
            const Text(
              'Livestock Grazing',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Livestock grazing is the practice of allowing domesticated animals, like cattle or sheep, to feed on vegetation in specific areas such as pastures. This traditional method offers various advantages when managed sustainably. Grazing helps regulate vegetation growth, aids in nutrient cycling through the deposition of animal manure, fosters biodiversity by preventing the dominance of certain plant species, and serves as a source of income for farmers through the sale of livestock products like meat or wool.However, unsustainable grazing practices can lead to environmental issues, including soil erosion, degradation of vegetation, and loss of biodiversity. Therefore, it\'s vital to implement responsible management techniques such as rotational grazing, where animals are moved between different grazing areas to allow vegetation recovery. This ensures a balance between livestock production and environmental conservation, promoting the long-term health of both the land and the animals.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Description :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            buildSectionTitle(context, 'What is livestock grazing?'),
            buildSectionContent(
                '1. Food Security: Livestock provides a significant source of animal protein in the form of meat, milk, and eggs, which are essential components of human diets worldwide. Livestock products contribute to food security by supplying essential nutrients and energy, especially in regions where access to other protein sources may be limited.\n'),
            const SizedBox(height: 8.0),
            buildSectionContent(
                '2. Livelihoods: Livestock farming supports the livelihoods of millions of people globally, particularly in rural areas. Small-scale farmers and pastoralists rely on livestock for income generation, employment opportunities, and economic stability. Livestock farming provides a source of income through the sale of livestock products, as well as employment in various sectors such as animal husbandry, veterinary services, and meat processing.\n'),
            const SizedBox(height: 16.0),
            buildSectionTitle(
                context, 'Why Livestock Grazing is important to us?'),
            buildSectionContent(
                '3. Nutrient Cycling: Livestock play a crucial role in nutrient cycling within agricultural ecosystems. Animal manure is a valuable source of organic matter and nutrients, such as nitrogen and phosphorus, which can be recycled back into the soil as fertilizer. This improves soil fertility, enhances crop yields, and reduces the need for synthetic fertilizers, contributing to sustainable agriculture practices.\n'),
            buildBulletPoint(context, 'Food Security:'),
            buildBulletContent(
                '4. Draught Power: In many regions, especially in developing countries, livestock serve as important sources of draught power for agricultural activities such as plowing, hauling, and transportation. Oxen, horses, and other draft animals provide valuable labor for farmers, enabling them to cultivate crops and carry out other essential farm tasks.'),
            buildBulletPoint(context, 'Environmental Conservation:'),
            const SizedBox(height: 16.0),
            const Text(
              'Quests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            FutureBuilder<Map<String, dynamic>>(
              future: _campaign1DetailsFuture,
              builder: (context, snapshot) {
                return _buildCampaignDetails(
                  context,
                  snapshot,
                  campaigns[7],
                  questions1,
                  options1,
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
                  campaigns[8],
                  questions2,
                  options2,
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
                  campaigns[9],
                  questions3,
                  options3,
                );
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
      List<String> questions,
      List<List<String>> options) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return const Text('Error fetching campaign details');
    } else if (!snapshot.hasData) {
      return const Text('No Details found');
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
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: getCampaignStatusColor(
                          campaignStatus,
                          startDate,
                          endDate,
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
                          builder: (context) => LiveStockQuestScreen(
                            campaign: campaign,
                            questions: questions,
                            options: options,
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
