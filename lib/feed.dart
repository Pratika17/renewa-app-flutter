import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:renewa/screens/newFeatures/leaderboard.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String? userId;
  String? loggedInUserName;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _fetchUserName(userId!);
    }
  }

  /// Fetch logged-in user's name once
  Future<void> _fetchUserName(String userId) async {
    final userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (userSnapshot.exists) {
      setState(() {
        loggedInUserName = userSnapshot['user_name'];
      });
    }
  }

  /// Handles adding or removing likes
  Future<void> _toggleLike(String submissionId) async {
    if (userId == null) return;

    final likeRef = FirebaseFirestore.instance
        .collection('Submissions')
        .doc(submissionId)
        .collection('Likes')
        .doc(userId);

    final likeSnapshot = await likeRef.get();
    if (likeSnapshot.exists) {
      await likeRef.delete(); // Unlike
    } else {
      await likeRef.set({'timestamp': FieldValue.serverTimestamp()}); // Like
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null || loggedInUserName == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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

      /// Fetch all submissions in one StreamBuilder
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Submissions')
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
              final submissionUserName = submission['user_name'];
              final campaignId = submission['campaign_id'];

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
                          Text(
                            'Campaign: $campaignId',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Posted by: $submissionUserName'),
                          const SizedBox(height: 8),

                          /// StreamBuilder for likes (optimized)
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Submissions')
                                .doc(submissionId)
                                .collection('Likes')
                                .snapshots(),
                            builder: (context, likeSnapshot) {
                              if (!likeSnapshot.hasData) return const Text('Likes: 0');
                              
                              final likeCount = likeSnapshot.data!.docs.length;
                              final isLiked = likeSnapshot.data!.docs.any((doc) => doc.id == userId);

                              return Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: isLiked ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () => _toggleLike(submissionId),
                                  ),
                                  Text('Likes: $likeCount'),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          /// StreamBuilder for comments (optimized)
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Submissions')
                                .doc(submissionId)
                                .collection('Comments')
                                .snapshots(),
                            builder: (context, commentSnapshot) {
                              if (!commentSnapshot.hasData) return const Text('No comments yet.');

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

                          /// Add Comment Button
                          IconButton(
                            icon: const Icon(Icons.comment),
                            onPressed: () {
                              _showCommentDialog(context, submissionId);
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
      ),
    );
  }

  /// Show comment input dialog
  void _showCommentDialog(BuildContext context, String submissionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add a Comment'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter your comment',
          ),
          onSubmitted: (value) {
            if (value.trim().isEmpty) return;
            FirebaseFirestore.instance
                .collection('Submissions')
                .doc(submissionId)
                .collection('Comments')
                .add({
              'comment': value.trim(),
              'user_id': userId,
              'user_name': loggedInUserName,
              'timestamp': FieldValue.serverTimestamp(),
            });
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }
}
