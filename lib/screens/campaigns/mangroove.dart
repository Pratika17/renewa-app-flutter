import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:renewa/data/campaigns_data.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/campaigns/eventsman.dart';
import 'package:renewa/screens/campaigns/questmangrove.dart';

class MangroveScreen extends StatelessWidget {
  MangroveScreen({super.key});

  final Campaign campaign = campaigns[4];
  final Campaign campaign1 = campaigns[5];
  final List<String> questions1 = [
    'What are mangroves, and where are they typically found?',
    'What are the benefits of mangrove planting?',
    'What are the challenges of mangrove planting?',
  ];

  final List<List<String>> options1 = [
    [
      'a) Mangroves are freshwater plants found in tropical rainforests.',
      'b) Mangroves are salt-tolerant trees found in coastal areas.',
      'c) Mangroves are desert shrubs found in arid regions',
      'd) Mangroves are aquatic plants found in ponds.'
    ],
    [
      'a) Mangroves are a good source of water for agriculture.',
      'b) Mangroves are a good source of nutrients for agriculture.',
      'c) Mangroves are a good source of fertilizers for agriculture.',
      'd) Mangroves provide habitat for diverse marine life.'
    ],
    [
      'a) Mangroves are a good source of water for agriculture.',
      'b) Mangroves are a good source of nutrients for agriculture.',
      'c) Mangroves are a good source of fertilizers for agriculture.',
      'd) Mangroves face threats from coastal development and pollution.'
    ]
  ];

  final List<String> questions2 = [
    'How do mangroves contribute to carbon sequestration?',
    'What types of mangrove species exist?',
    'How do mangroves support biodiversity?',
  ];

  final List<List<String>> options2 = [
    [
      'a) They release carbon dioxide into the atmosphere.',
      'b) They store carbon in their roots and soil.',
      'c) They do not contribute to carbon sequestration.',
      'd) They convert carbon dioxide into oxygen.'
    ],
    [
      'a) Only one species of mangrove exists.',
      'b) Mangroves include red, black, and white species.',
      'c) Mangroves are divided into terrestrial and aquatic species.',
      'd) There are no distinct mangrove species.'
    ],
    [
      'a) Mangroves do not support biodiversity.',
      'b) Mangroves provide habitat for a variety of marine and terrestrial species.',
      'c) Mangroves are important for agricultural biodiversity.',
      'd) Mangroves are known for supporting only fish species.'
    ]
  ];

  final List<String> questions3 = [
    'What human activities threaten mangroves?',
    'How can mangrove restoration be achieved?',
    'What role do mangroves play in coastal protection?',
  ];

  final List<List<String>> options3 = [
    [
      'a) Sustainable tourism.',
      'b) Industrial pollution and coastal development.',
      'c) Organic farming.',
      'd) Conservation efforts.'
    ],
    [
      'a) By cutting down more mangroves.',
      'b) Through replanting and conservation initiatives.',
      'c) By converting mangroves into agricultural land.',
      'd) By ignoring their existence.'
    ],
    [
      'a) Mangroves have no role in coastal protection.',
      'b) Mangroves help reduce erosion and storm surge impacts.',
      'c) Mangroves increase coastal erosion.',
      'd) Mangroves create barriers that obstruct coastal views.'
    ]
  ];

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
      return const Color.fromRGBO(254, 249, 195, 1);
    } else if (now.isAfter(campaign.specificEndDate)) {
      return const Color.fromRGBO(217, 217, 217, 1);
    } else {
      return const Color.fromRGBO(174, 239, 188, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mangrove Matters',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => MangroveEventsScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(174, 239, 188, 1),
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'Ongoing Events',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/man.png'),
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
            buildSectionTitle('Description :'),
            const SizedBox(height: 8.0),
            buildSectionTitle('What is mangrove matters?'),
            buildSectionContent(
              '“Mangrove Matters” is an engaging initiative aimed at promoting awareness and fostering appreciation for mangrove conservation and restoration efforts. Mangrove Matters hosts online quizzes on its website, featuring questions about mangrove ecology, biodiversity, conservation challenges, and success stories. Participants can test their knowledge, learn new facts, and earn points or badges for correct answers, incentivizing engagement and learning. Mangrove Matters organizes offline events such as workshops, seminars, beach clean-ups, and tree planting activities in coastal communities and schools and also promotes them on our website making a difference for mangrove and coastal communities worldwide.',
            ),
            const SizedBox(height: 16.0),
            buildSectionTitle('Why Learn About Mangrove Matters?'),
            buildBulletContent(
              '1. Coastal protection: Mangrove forests act as natural barriers, reducing the impact of coastal erosion, storm surges, and tsunamis. Their dense root systems stabilize shorelines and mitigate the damaging effects of waves and currents, protecting coastal communities and infrastructure.',
            ),
            buildBulletContent(
              '2. Water filtration: Mangrove roots filter sediment and trap pollutants, improving water quality and clarity in coastal areas. They help prevent runoff and nutrient pollution from entering marine ecosystems, maintaining the health of coral reefs and seagrass beds that rely on clear water for photosynthesis and growth.',
            ),
            buildBulletContent(
              '3. Carbon sequestration: Mangrove trees are highly efficient at capturing and storing carbon dioxide from the atmosphere. Their submerged roots and organic-rich soil trap carbon, making mangrove forests one of the most effective natural carbon sinks on the planet. Protecting and restoring mangrove habitats can help mitigate climate change by reducing greenhouse gas emissions and much more.',
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Quests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildCampaignDetails(context, getCampaignStatus(campaigns[15]),
                campaigns[15], questions1, options1),
            const SizedBox(height: 16.0),
            _buildCampaignDetails(context, getCampaignStatus(campaigns[16]),
                campaigns[16], questions2, options2),
            const SizedBox(height: 16.0),
            _buildCampaignDetails(context, getCampaignStatus(campaigns[17]),
                campaigns[17], questions3, options3),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
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

  Widget buildBulletContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildCampaignDetails(BuildContext context, String campaignStatus,
      Campaign campaign, List<String> questions, List<List<String>> options) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          borderRadius:
              BorderRadius.circular(35.0), // Apply border radius here as well
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
                      backgroundColor: getCampaignStatusColor(campaign),
                      foregroundColor: Colors.black,
                    ),
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
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MangroveQuestScreen(
                              campaign: campaign,
                              questions: questions,
                              options: options),
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
