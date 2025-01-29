import 'package:flutter/material.dart';
import 'package:renewa/models/campaign_model.dart';
import 'package:renewa/screens/newFeatures/citizen_credit.dart';
import 'package:renewa/screens/newFeatures/citizen_reports.dart';
import 'package:renewa/screens/newFeatures/citizen_upload.dart';
class CitizenScreen extends StatelessWidget {
  const CitizenScreen({super.key, required this.campaign,required this.collectionName});
   final Campaign campaign;
   final String collectionName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(''),
      ),
       body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const SizedBox(height: 8),
             const Text(
                  'Citizen',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
               const SizedBox(height: 32),
            _buildButtons(context),
          ],
        ),
    ),

    );
  }
  Widget _buildButtons(BuildContext context) {
     return  Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
              onPressed: () {
               Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CitizenUploadScreen(campaign: campaign,),
        ));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 175, 226, 130),
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: const Text("New report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black))),
        
             const SizedBox(height: 16),

           ElevatedButton(
            onPressed: () {
               Navigator.of(context).push(
                      MaterialPageRoute(
                         builder: (context) => const CitizenReportsScreen(),
                     ),
                   );
            },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 175, 226, 130),
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: const Text(
                "Reports done",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
              )),

               const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                 Navigator.of(context).push(
                      MaterialPageRoute(
                         builder: (context) => CitizenCreditScreen(),
                     ),
                   );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 175, 226, 130),
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: const Text(
                "Withdraw",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
              )),
              
        ],
      );

  }
}