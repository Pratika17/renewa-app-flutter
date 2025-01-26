import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  // Fetch leaderboard data
  Future<List<Map<String, dynamic>>> _fetchLeaderboardData() async {
    // Fetch all users
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('Users').get();
    
    // Map to store user email -> user data
    Map<String, Map<String, dynamic>> userMap = {};

    for(var userDoc in usersSnapshot.docs){
      userMap[userDoc['user_email']] = userDoc.data();
    }

     // Debug: Log fetched users
    print('Users: ${userMap}');


    // Fetch all submissions
    final submissionsSnapshot =
        await FirebaseFirestore.instance.collection('Submissions').get();

    // Debug: Log fetched submissions
    print('Submissions: ${submissionsSnapshot.docs.map((doc) => doc.data())}');


    // Map to store user email -> submission count
    Map<String, int> submissionCounts = {};

    // Count submissions per user
    for (var submissionDoc in submissionsSnapshot.docs) {
      final userEmail = submissionDoc['user_email'];
      if (userEmail != null) { //check for nulls
       if (submissionCounts.containsKey(userEmail)) {
         submissionCounts[userEmail] = submissionCounts[userEmail]! + 1;
       } else {
        submissionCounts[userEmail] = 1;
      }
      }

    }


    // Debug: Log submission counts
    print('Submission Counts: $submissionCounts');

    // Prepare leaderboard data
    List<Map<String, dynamic>> leaderboardData = [];

    // Iterate through submission counts
    submissionCounts.forEach((userEmail, submissionCount) {
      final userData = userMap[userEmail];
      if (userData != null) {
        leaderboardData.add({
          'name': userData['user_name'],
          'imageUrl': userData['imageUrl'] ?? '',
          'score': submissionCount,
        });
      }
     });

    // Sort leaderboard by score in descending order
    leaderboardData.sort((a, b) => b['score'].compareTo(a['score']));

    // Debug: Log sorted leaderboard data
    print('Sorted Leaderboard Data: $leaderboardData');

    return leaderboardData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),

      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLeaderboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             print('Error: ${snapshot.error}');
            return const Center(child: Text('Error fetching leaderboard.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No leaderboard data available.'));
          }

          final leaderboardData = snapshot.data!;

          return ListView.builder(
            itemCount: leaderboardData.length,
            itemBuilder: (context, index) {
              final userData = leaderboardData[index];
              final userName = userData['name'];
              final userImageUrl = userData['imageUrl'];
              final userScore = userData['score'];

              return Card(
                color: const Color.fromARGB(255, 136, 229, 156),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: userImageUrl.isNotEmpty
                        ? NetworkImage(userImageUrl)
                        : null,
                    child: userImageUrl.isEmpty
                        ? const Icon(Icons.person) // Placeholder for missing image
                        : null,
                  ),
                  title: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  subtitle: Text('Submissions: $userScore',style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}