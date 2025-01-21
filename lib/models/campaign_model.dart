// lib/models/campaign_model.dart
class Campaign {
  final String id;
  final String title;
  final String imagePath;
  final String description;
  final String? collectionName;
  final String status;
  final int credits;
  final int participants;
  final String outcomes;
  final String introduction;
  final String deliverables;
  final DateTime startDate; 
  final DateTime specificEndDate;
  final List<String> quest;
  final String? region;

  Campaign({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.description,
    this.collectionName,
    required this.status,
    required this.credits,
    required this.participants,
    required this.outcomes,
    required this.introduction,
    required this.deliverables,
    required this.startDate,
    required this.specificEndDate,
    required this.quest,
    this.region,
  });
}
