import 'package:flutter/material.dart';


class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pop until GreenCampaignsScreen is reached
            Navigator.of(context).popUntil((route) => route.settings.name == '/home');
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              color: const Color.fromARGB(255, 208, 207, 207), // Light grey color
              child: const Text(
                'Thank you!\nFor taking part in the quest.\nWe’ll verify the details and promptly inform you of the outcome.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
