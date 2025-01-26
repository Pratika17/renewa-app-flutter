import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CitizenCreditScreen extends StatelessWidget {
  CitizenCreditScreen({super.key});
  final authenticatedUser = FirebaseAuth.instance.currentUser!;

  Future<Map<String, dynamic>> _getEarningsData() async {
    final earningsDoc = await FirebaseFirestore.instance
        .collection('Earnings')
        .doc('Credits and Money')
        .get();
    return earningsDoc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getEarningsData(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No data available');
            } else {
              final data = snapshot.data!;
              return Container(
                padding: const EdgeInsets.only(right: 20, left: 20, top: 60, bottom: 150),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Earnings',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Rs.${data['Current Balance'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Total Withdrawn :  Rs.${data['Total Withdrawn'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Balance :  Rs.${data['Current Balance'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Redeemed Credit Points :  ${data['Redeemed Credit Points']}',
                      style: const TextStyle(
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Credit Points :  ${data['Current Credit Points']}',
                      style: const TextStyle(
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
