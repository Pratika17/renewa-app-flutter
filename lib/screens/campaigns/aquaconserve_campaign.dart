
import 'package:flutter/material.dart';
import 'package:renewa/data/campaigns_data.dart';

import 'package:renewa/screens/campaigns/domestic.dart';

class AquaConserveCampaignScreen extends StatelessWidget {
  const AquaConserveCampaignScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaConserve', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
          Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/wave.png'),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AquaConserve',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Aqua Conserve introduces a pioneering concept to incentivize environmentally conscious behaviors by rewarding individuals for engaging in sustainable practices related to water conservation. Participants earn rewards for capturing and uploading photos of eco-friendly actions such as recycling greywater, utilizing water-efficient fixtures. By participating in Aqua Conserve, individuals not only contribute to global water sustainability efforts but also receive recognition and incentives for their commitment to a greener planet.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(

                    'Featured Pathways',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      
                      GestureDetector(
                        onTap:(){ Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => DomesticScreen(campaign: campaigns[2],)));},
                        child: const PathwayCard(
                          image: 'assets/images/domestic.png',
                          title: 'Domestic',
                        ),
                      ),
              
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PathwayCard extends StatelessWidget {
  const PathwayCard({super.key, required this.image, required this.title});
  final String image;
  final String title;


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.asset(image, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          
        ],
      ),
    );
  }
}