import 'package:flutter/material.dart';

class CouponsJuniorScreen extends StatelessWidget {
  const CouponsJuniorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey.shade200,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Green Credit for Junior Citizens',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Empowering eco-friendly living for every generation',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Image.asset(
                'assets/images/amazon1.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Image.asset(
                'assets/images/pvr2.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Image.asset(
                'assets/images/pvr2.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Image.asset(
                'assets/images/lifestyle.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
