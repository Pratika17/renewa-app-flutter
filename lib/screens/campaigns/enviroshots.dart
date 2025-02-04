import 'package:flutter/material.dart';
import 'package:renewa/data/campaigns_data.dart';

import 'package:renewa/screens/campaigns/recycling.dart';

class EnviroshotsScreen extends StatelessWidget {
  const EnviroshotsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EnviroShots', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
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
            Image.asset('assets/images/enviro.png'),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EnviroShots',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Introduces a novel concept to incentivize environmentally-conscious actions by rewarding individuals for taking a picture of trash and tagging its location. By simply capturing and uploading pictures of of trash and tagging location, participants not only contribute to a greener planet but also earn rewards for their efforts.',
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
                        onTap:(){ Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => RecyclingScreen  (campaign: campaigns[13],)));},
                        child: const PathwayCard(
                          
                          image: 'assets/images/recycle.png',
                          title: 'Recycling',
                        
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