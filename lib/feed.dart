import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Submissions')
            .where('campaign_id', isEqualTo: 'GreenSnap') // Filter by campaign
            .orderBy('created_at', descending: true) // Order by latest submissions
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No submissions found.'));
          }

          final submissions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              return FeedItem(submission: submission);
            },
          );
        },
      ),
    );
  }
}

class FeedItem extends StatefulWidget {
  final QueryDocumentSnapshot submission;

  const FeedItem({super.key, required this.submission});

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchLikes();
  }

  Future<void> _fetchLikes() async {
    final likeSnapshot = await FirebaseFirestore.instance
        .collection('Likes')
        .where('submission_id', isEqualTo: widget.submission.id)
        .get();

    setState(() {
      _likeCount = likeSnapshot.docs.length;
      _isLiked = likeSnapshot.docs
          .any((doc) => doc['user_id'] == 'current_user_id'); // Replace with your current user's ID logic
    });
  }

  Future<void> _toggleLike() async {
    final userId = 'current_user_id'; // Replace with your current user's ID logic

    if (_isLiked) {
      // Unlike
      final likeSnapshot = await FirebaseFirestore.instance
          .collection('Likes')
          .where('submission_id', isEqualTo: widget.submission.id)
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in likeSnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _isLiked = false;
        _likeCount--;
      });
    } else {
      // Like
      await FirebaseFirestore.instance.collection('Likes').add({
        'submission_id': widget.submission.id,
        'user_id': userId,
        'created_at': DateTime.now(),
      });

      setState(() {
        _isLiked = true;
        _likeCount++;
      });
    }
  }

  void _openComments() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CommentsScreen(submissionId: widget.submission.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.submission.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (data['photo_url'] != null)
            Image.network(
              data['photo_url'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          // Location
          if (data['location'] != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '📍 ${data['location']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          // Description
          if (data['description'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(data['description']),
            ),
          const SizedBox(height: 8),
          // Likes and Comments Actions
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: _toggleLike,
              ),
              Text('$_likeCount likes'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: _openComments,
              ),
              const Text('Comments'),
            ],
          ),
        ],
      ),
    );
  }
}

class CommentsScreen extends StatelessWidget {
  final String submissionId;

  const CommentsScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Comments')
                  .where('submission_id', isEqualTo: submissionId)
                  .orderBy('created_at', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(comment['user_id']),
                      subtitle: Text(comment['comment_text']),
                    );
                  },
                );
              },
            ),
          ),
          // Add Comment Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(labelText: 'Add a comment'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final commentText = commentController.text.trim();
                    if (commentText.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('Comments').add({
                        'submission_id': submissionId,
                        'user_id': 'current_user_id', // Replace with actual user ID
                        'comment_text': commentText,
                        'created_at': DateTime.now(),
                      });
                      commentController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
