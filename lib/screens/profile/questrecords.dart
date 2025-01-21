import 'package:flutter/material.dart';

class Quest {
  final String title;
  final String status;
  final String submissionStatus;
  final DateTime endDate;
  final String additionalInfo;

  Quest({
    required this.title,
    required this.status,
    required this.submissionStatus,
    required this.endDate,
    required this.additionalInfo,
  });
}

class QuestRecordsScreen extends StatelessWidget {
  QuestRecordsScreen({super.key});
  final List<Quest> quests = [
    Quest(
      title: 'Quest 1 - Agricultural Applications',
      status: 'Ongoing',
      submissionStatus: 'Submitted',
      endDate: DateTime(2024, 4, 23, 21, 30),
      additionalInfo: 'Ending on April 23, 2024, 09:30 pm',
    ),
    Quest(
      title: 'Quest 3 - Mangrove Conservation',
      status: 'Past',
      submissionStatus: 'Not Submitted',
      endDate: DateTime(2024, 3, 15, 18, 00),
      additionalInfo:
          'Submission deadline has passed, but you can still review the content.',
    ),
    Quest(
      title: 'Quest 3 - Environmental Impacts',
      status: 'Past',
      submissionStatus: 'Rewarded',
      endDate: DateTime(2024, 3, 10, 17, 00),
      additionalInfo: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quest Records',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: quests.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: buildQuestCard(quests[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuestCard(Quest quest) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quest.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                buildStatusChip(quest.status),
                const SizedBox(width: 8),
                buildStatusChip(quest.submissionStatus),
              ],
            ),
            const SizedBox(height: 8),
            if (quest.additionalInfo.isNotEmpty)
              Text(
                quest.additionalInfo,
                style: TextStyle(
                  fontSize: 14,
                  color: quest.status == 'Past' &&
                          quest.submissionStatus == 'Not Submitted'
                      ? Colors.red
                      : Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildStatusChip(String status) {
    Color backgroundColor;
    Color fontColor;
    if (status == 'Ongoing') {
      backgroundColor = const Color.fromRGBO(174, 239, 188, 1);
      fontColor = Colors.black;
    } else if (status == 'Submitted' || status == 'Not Submitted') {
      backgroundColor =
          const Color.fromARGB(255, 195, 197, 196).withOpacity(1);
      fontColor = Colors.black;
    } else if (status == 'Rewarded') {
      backgroundColor = const Color.fromRGBO(27, 142, 123, 1);
      fontColor = Colors.white;
    } else {
      backgroundColor = const Color.fromRGBO(217, 217, 217, 1);
      fontColor = Colors.black;
    }

    return Chip(
      backgroundColor: backgroundColor,
      label: Text(
        status,
        style: TextStyle(fontWeight: FontWeight.bold, color: fontColor),
      ),
    );
  }
}
