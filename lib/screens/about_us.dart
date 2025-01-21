import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF004D40), // Dark green color
              Color(0xFF00796B), // Medium green color
              Color(0xFF009688), // Light green color
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/images/about-us.png"), // Use the provided image path
              const SizedBox(height: 10),
              const Text(
                'Green Credit Management: Empowering Sustainable Financial Solutions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'In the face of escalating environmental challenges, the financial sector has a pivotal role in driving sustainability initiatives. Our project, "RENEWA" addresses the urgent need for innovative solutions to integrate environmental considerations into financial systems. By introducing eco-missions and green campaigns, our team aims to develop a dynamic platform that encourages sustainable eco-friendly practices..\n\n'
                'Our solution encompasses several key features, including:\n'
                '1. Eco-missions & Green campaigns: The Green campaigns page introduces the theme or events related to Eco-missions, outlining the journey players will experience during their environmental journey. No registration for Green campaigns is necessary; simply jump into the Eco-missions and begin your participation!\n'
                '2. Green Credit Framework: Designing a strong system of incentives to encourage citizens to adopt eco-friendly practices and investments through rewards, thereby fostering a greener economy.\n'
                '3. Reward System: Creating intuitive dashboards and visualizations to provide players with Eco-missions cleared and rewarded for their environmental performance and credit management strategies.\n'
                '4. Community Engagement: Encouraging environmentalists to work together with activists, experts, and policymakers to save resources for sustainable resource management.\n\n'
                'Through our innovative approach, we aim to promote efficient resource usage and create a sustainable environment simultaneously. Every Green campaign consists of multiple Eco-missions featuring user-friendly content, offering detailed guidance to assist players in order to use the resources efficiently and creating a cleaner and greener environment. At the end of each Eco-mission, a required deliverable must be submitted promptly within the Eco-missions in the specified timeframe. Players must take note of the Eco-missions start and end dates to ensure timely completion and stay ahead of the game! Join us in revolutionizing the finance industry and paving the way for a greener, more prosperous future.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}