import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardScreen extends StatefulWidget {
  final String docId;
  final String acceptedBy;
  final Map<String, dynamic>? submissionLocations;
  final String userEmail;

  const RewardScreen({
    super.key,
    required this.docId,
    this.submissionLocations,
    required this.acceptedBy,
    required this.userEmail,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final _amountController = TextEditingController();
  bool _isAwarding = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _awardCredits() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) {
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null) {
      return;
    }
    setState(() {
      _isAwarding = true;
    });
    try {
      final submissionDoc = await FirebaseFirestore.instance
          .collection('Submissions')
          .doc(widget.docId)
          .get();

      final userEmail = submissionDoc['user_email'];

      final userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_email', isEqualTo: userEmail)
          .get();
      final acceptedByQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_email', isEqualTo: widget.acceptedBy)
          .get();
      final profitQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('user_email', isEqualTo: "pratika7prem7@gmail.com")
          .get();
        print(userEmail);
        print(widget.acceptedBy);

      if (userQuery.docs.isEmpty ||
          acceptedByQuery.docs.isEmpty ||
          profitQuery.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found!')),
          );
        }
      }

      final userDocId = userQuery.docs.first.id;
      final acceptedByDocId = acceptedByQuery.docs.first.id;
      final profitDocId = profitQuery.docs.first.id;

      final awardUserAmount = amount * 0.25;
      final awardAcceptedUserAmount = amount * 0.65;
      final awardProfitAmount = amount * 0.1;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userDocId)
          .update({
        'recycle_award': FieldValue.increment(awardUserAmount),
      });

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(acceptedByDocId)
          .update({
        'recycle_award': FieldValue.increment(awardAcceptedUserAmount),
      });

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(profitDocId)
          .update({
        'recycle_profit': FieldValue.increment(awardProfitAmount),
      });

      await FirebaseFirestore.instance
          .collection('Submissions')
          .doc(widget.docId)
          .update({
        'status': 'rewarded',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credits Awarded Successfully')),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error awarding credits: $e')),
        );
      }
    } finally {
      setState(() {
        _isAwarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(27, 142, 123, 1),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isAwarding ? null : _awardCredits,
                icon: _isAwarding
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Icon(Icons.arrow_forward),
                label: _isAwarding
                    ? const Text("Awarding...")
                    : const Text('Award'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
