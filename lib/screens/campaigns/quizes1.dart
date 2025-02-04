import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String questTitle; // Changed to questTitle
  final String campaignTitle;
  final List<Map<String, dynamic>> questions;
  final List<List<String>> options;

  const QuizScreen({
    super.key,
    required this.questTitle,
    required this.campaignTitle,
    required this.questions,
    required this.options,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  List<String?> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _userAnswers = List<String?>.filled(widget.questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.questTitle}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_questionIndex + 1} of ${widget.questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              widget.questions[_questionIndex]['text'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              widget.options[_questionIndex].length,
              (index) => RadioListTile(
                title: Text(widget.options[_questionIndex][index]),
                value: widget.options[_questionIndex][index],
                groupValue: _selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value;
                    _userAnswers[_questionIndex] = value; // Store user's answer
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: _selectedAnswer == null
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswer = null;
                      });

                      // Move to the next question or show the result
                      if (_questionIndex < widget.questions.length - 1) {
                        setState(() {
                          _questionIndex++;
                        });
                      } else {
                        _submitQuiz(); // Call submit quiz function
                      }
                    },
              child: Text(_questionIndex < widget.questions.length - 1
                  ? 'Next Question'
                  : 'Submit Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuiz() async {
  int tempScore = 0; // Local score to calculate before updating state

  // Calculate the score and add submission to Firestore
  for (int i = 0; i < widget.questions.length; i++) {
    // Get the correct answer ID from the question
    final String correctAnswerId = widget.questions[i]['correctAnswer'];

    // Find the correct option text that corresponds to the correct answer ID
    try {
      final correctOption = widget.questions[i]['options'].firstWhere(
          (option) => option['text'] == _userAnswers[i]);

      if (_userAnswers[i] == correctOption['text']) {
        tempScore++;
      }
    } catch (e) {
      // Handle the case where no matching option is found (or other errors)
      print('Error finding correct option: $e');
      // You might want to log this or take other actions.
      // It could mean your data in Firestore is inconsistent.
    }
  }

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch user data from 'Users' collection
      final userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_email', isEqualTo: user.email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        final userName = userData['user_name'];
        String questName = widget.questTitle; // Use widget.questTitle directly
        // Add submission to 'QSubmissions' collection
        await FirebaseFirestore.instance.collection('QSubmissions').add({
          'user_name': userName,
          'user_email': user.email,
          'created_at': FieldValue.serverTimestamp(),
          'quest_name': questName,
          'status': 'pending',
          'answers': _userAnswers,
          'score': tempScore, // Store the score
          'campaignTitle': widget.campaignTitle,
        });

        // Show the result
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Quiz Result'),
              content: Text(
                  'You scored $tempScore out of ${widget.questions.length}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Go back to the previous screen
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle the case where user data is not found
        print('User data not found in "Users" collection');
      }
    }
  } catch (e) {
    print('Error submitting quiz: $e');
    // Handle errors
  }
}
}