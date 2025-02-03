import 'package:flutter/material.dart';
import 'package:renewa/data/campaigns_data.dart';
import 'package:renewa/screens/campaigns/covercropping.dart';
import 'package:renewa/screens/campaigns/terrace.dart';

class EcoHarvestScreen extends StatelessWidget {
  const EcoHarvestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Harvest', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
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
            Image.asset('assets/images/ecoharvest.png'),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Eco Harvest',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Farming is leading the charge in promoting sustainable agriculture. Through incentivizing and advocating eco-friendly practices like terrace farming, cover cropping, livestock grazing, and drip irrigation, we\'re transforming the agricultural landscape. Participants are rewarded for capturing and sharing snapshots of their sustainable farming activities, amplifying awareness and spreading the word about the benefits of sustainable agriculture. Join us in this revolutionary initiative and be part of the solution for a greener future!',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Featured Pathways',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      GestureDetector(
                        onTap:(){ Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => TerraceScreen(campaign: campaigns[3],)));},
                        child: const PathwayCard(
                          
                          image: 'assets/images/terrace.png',
                          title: 'Terrace Farming',
                        ),
                      ),
                      GestureDetector(
                        onTap:(){ Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => CoverCroppingScreen()));},
                        child: const PathwayCard(
                          image: 'assets/images/cc.png',
                          title: 'Cover Cropping',
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
  final String image;
  final String title;

  const PathwayCard({super.key, required this.image, required this.title});

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