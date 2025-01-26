import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:renewa/screens/newFeatures/leaderboard.dart';

class CitizenReportsScreen extends StatelessWidget {
  const CitizenReportsScreen({super.key});

  // Fetch logged-in user information from the Users collection
  Future<String> _getLoggedInUserName(String userId) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();

    if (userSnapshot.exists) {
      return userSnapshot['user_name']; // Return the user_name field
    }
    return 'Unknown User'; // In case the user document doesn't exist
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    print(userEmail); // Get current user's ID
    
    if (userId == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Submissions')
             .where('campaign_id',isEqualTo: 'Recycling')
             .where('user_email',isEqualTo: userEmail)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No submissions available.'));
          }

          final submissions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              
              final imageUrl = submission['photo_url'];
              final location = submission['location'];
              
              final campaignStatus = submission['status'];


              return FutureBuilder<String>(
                future: _getLoggedInUserName(userId), // Fetch logged-in user name
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return const Center(child: Text('Error fetching user info.'));
                  }
                  final loggedInUserName = userSnapshot.data!;


                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(imageUrl, fit: BoxFit.cover),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location: $location',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Status : $campaignStatus',style: const TextStyle(fontWeight: FontWeight.bold),),
                              
                            ]
                          )
                        )
                      ]
                    )
                  );     
                },
              );
            },
          );
        },
      ),
    );
  }
}
