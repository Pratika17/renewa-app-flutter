import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:renewa/data/boxes_data.dart';
import 'package:renewa/data/campaigns_data.dart';
import 'package:renewa/screens/about_us.dart';
import 'package:renewa/screens/campaigns/aquaconserve_campaign.dart';
import 'package:renewa/screens/campaigns/cleancommute.dart';
import 'package:renewa/screens/campaigns/ecoharvest.dart';
import 'package:renewa/screens/campaigns/enviroshots.dart';
import 'package:renewa/screens/campaigns/greensnap_campaign.dart';
import 'package:renewa/screens/campaigns/mangroove.dart';
import 'package:renewa/screens/contactus_page.dart';
import 'package:renewa/widgets/main_drawer.dart';

class GreenCampignsScreen extends StatelessWidget {
  const GreenCampignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of screens corresponding to each box
    final List<Widget> screens = [
      GreenSnapCampaignScreen(
        campaign: campaigns[0],
      ),
      const AquaConserveCampaignScreen(),
      const EcoHarvestScreen(),
      CleanCommuteScreen(
        campaign: campaigns[12],
      ),
      const EnviroshotsScreen(),
      MangroveScreen(),
    ];

    return Scaffold(
      drawer: MainDrawer(),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Renewa-bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: const Icon(
                          Icons.menu,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Text(
                      'renewa', // Replace with your log.jpeg in assets
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AboutUsScreen()),
                            );
                          },
                          child: const Text(
                            'About Us',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContactUsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Contact Us',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 50.0,
                      crossAxisSpacing: 35.0,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: boxes.length,
                    itemBuilder: (context, index) {
                      final box = boxes[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx) => screens[index],
                                settings: const RouteSettings(name: "/home")),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(35.0),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      box.imagePath,
                                      width: 55,
                                      height: 55,
                                      alignment: Alignment.topLeft,
                                    ),
                                    Center(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          box.title,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
