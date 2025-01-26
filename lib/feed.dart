import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:renewa/screens/newFeatures/leaderboard.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

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

  Future<void> _addLike(String submissionId, String userId) async {
    final likeRef = FirebaseFirestore.instance
        .collection('Submissions')
        .doc(submissionId)
        .collection('Likes')
        .doc(userId); // Use the user_id as the document ID.

    final likeSnapshot = await likeRef.get();
    if (likeSnapshot.exists) {
      await likeRef.delete(); // Unlike the post
    } else {
      await likeRef.set({'timestamp': FieldValue.serverTimestamp()}); // Like the post
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid; // Get current user's ID
    
    if (userId == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
            child: const Text(
              'LeaderBoard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Submissions')
            .where('campaign_id', isEqualTo: 'GreenSnap')
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
              final submissionId = submission.id;
              final imageUrl = submission['photo_url'];
              final location = submission['location'];
              final submissionUserName = submission['user_name']; // "Posted by"
              final campaignId = submission['campaign_id'];


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
                              Text('Campaign : $campaignId',style: const TextStyle(fontWeight: FontWeight.bold),),
                              Text('Posted by: $submissionUserName'),
                              const SizedBox(height: 8),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Submissions')
                                    .doc(submissionId)
                                    .collection('Likes')
                                    .snapshots(),
                                builder: (context, likeSnapshot) {
                                  if (!likeSnapshot.hasData) {
                                    return const Text('Likes: 0');
                                  }
                                  final likeCount = likeSnapshot.data!.docs.length;
                                  final isLiked = likeSnapshot.data!.docs
                                      .any((doc) => doc.id == userId);

                                  return Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite,
                                          color: isLiked
                                              ? const Color.fromARGB(255, 243, 33, 33)
                                              : Colors.grey,
                                        ),
                                        onPressed: () => _addLike(submissionId, userId),
                                      ),
                                      Text('Likes: $likeCount'),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Submissions')
                                    .doc(submissionId)
                                    .collection('Comments')
                                    .snapshots(),
                                builder: (context, commentSnapshot) {
                                  if (!commentSnapshot.hasData) {
                                    return const Text('No comments yet.');
                                  }
                                  final comments = commentSnapshot.data!.docs;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: comments.map((comment) {
                                      return Text(
                                        '${comment['user_name']}: ${comment['comment']}',
                                        style: const TextStyle(fontStyle: FontStyle.italic),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              IconButton(
                                icon: const Icon(Icons.comment),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Add a Comment'),
                                      content: TextField(
                                        decoration: const InputDecoration(
                                          hintText: 'Enter your comment',
                                        ),
                                        onSubmitted: (value) {
                                          FirebaseFirestore.instance
                                              .collection('Submissions')
                                              .doc(submissionId)
                                              .collection('Comments')
                                              .add({
                                            'comment': value,
                                            'user_id': userId,
                                            
                                            'user_name': loggedInUserName,
                                            'timestamp': FieldValue.serverTimestamp(),
                                          });
                                          Navigator.of(ctx).pop();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
