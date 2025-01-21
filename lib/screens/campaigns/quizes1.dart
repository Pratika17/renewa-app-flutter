import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renewa/screens/thank_you.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.questions, required this.options, required this.campaignTitle, required this.questTitle});

  final List<String> questions;
  final List<List<String>> options;
  final String campaignTitle;
  final String questTitle;

  @override
  State<QuizScreen> createState() {
    return _QuizScreenState();
  }
}

class _QuizScreenState extends State<QuizScreen> {
  Map<int, Set<int>> selectedAnswers = {};
  bool isSubmitting = false;
  bool isSubmitted = false;
  bool isFinalCheck = false;

  @override
  void initState() {
    super.initState();
    checkSubmissionStatus();
  }

  Future<void> checkSubmissionStatus() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection(widget.campaignTitle)
        .doc(widget.questTitle)
        .get();

    setState(() {
      isSubmitted = docSnapshot.exists;
    });
  }

  Future<void> handleSubmit() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection(widget.campaignTitle)
          .doc(widget.questTitle)
          .set({
        'answers': selectedAnswers.map((key, value) => MapEntry(key.toString(), value.toList())),
      });

      setState(() {
        isSubmitted = true;
      });

      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const ThankYouScreen()));
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

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
      ),
      body: isSubmitted
          ? const Center(child: Text('You have already submitted your answers.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.questions.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.questions.length) {
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Your submission will be final and cannot be modified or withdrawn later. Please review your inputs carefully.'),
                        value: isFinalCheck,
                        onChanged: (bool? value) {
                          setState(() {
                            isFinalCheck = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: isFinalCheck && !isSubmitting ? handleSubmit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(30, 105, 92, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit'),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.questions[index],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.options[index].asMap().entries.map((entry) {
                      int optIndex = entry.key;
                      String option = entry.value;
                      return Column(
                        children: [
                          CheckboxListTile(
                            title: Text(option),
                            value: selectedAnswers[index]?.contains(optIndex) ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  if (selectedAnswers[index] == null) {
                                    selectedAnswers[index] = {};
                                  }
                                  selectedAnswers[index]?.add(optIndex);
                                } else {
                                  selectedAnswers[index]?.remove(optIndex);
                                }
                              });
                            },
                          ),
                          if (optIndex == widget.options[index].length - 1)
                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                              height: 20,
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
    );
  }
}
