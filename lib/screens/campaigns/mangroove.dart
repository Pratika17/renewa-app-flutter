import 'package:flutter/material.dart';
import 'package:renewa/screens/campaigns/eventsman.dart';


class MangroveScreen extends StatefulWidget {
  const MangroveScreen({super.key});

  @override
  _MangroveScreenState createState() {
    return _MangroveScreenState();
  }
}

class _MangroveScreenState extends State<MangroveScreen> {

  @override
  void initState() {
    super.initState();
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
}