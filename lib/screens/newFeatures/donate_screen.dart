import 'package:flutter/material.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your donations will help us engage in more environmental sustainable activities, such as:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              '- Supporting reforestation and afforestation projects.\n'
              '- Promoting sustainable agricultural practices.\n'
              '- Investing in renewable energy research and development.\n'
              '- Organizing community cleanup events.\n'
              '- Educating people about environmental conservation.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                //Implement Donation Logic here (e.g., navigate to a payment gateway)
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Donation Feature"),
                        content: const Text(
                            "Donation feature will be added soon! Stay tuned for updates!"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Close"),
                          ),
                        ],
                      );
                    });
              },
              child: const Text('Donate Now'),
            ),
          ],
        ),
      ),
    );
  }
}