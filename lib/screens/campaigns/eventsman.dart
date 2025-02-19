import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A simple model class to represent an offline event.
class OfflineEvent {
  final String id;
  final String name;
  final String location;
  final DateTime dateTime;

  OfflineEvent({
    required this.id,
    required this.name,
    required this.location,
    required this.dateTime,
  });

  /// Factory constructor to create an `OfflineEvent` from a Firestore document.
  factory OfflineEvent.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OfflineEvent(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      // If 'datetime' is stored as a Firestore Timestamp:
      dateTime: (data['datetime'] as Timestamp).toDate(),
      // If 'datetime' is stored as a string, parse it:
      // dateTime: DateTime.parse(data['datetime'] as String),
    );
  }
}

/// The main screen that displays all offline events using a `StreamBuilder`.
class MangroveEventsScreen extends StatelessWidget {
  const MangroveEventsScreen({Key? key}) : super(key: key);

  /// Determines the status of an event based on the current time and event time.
  String getEventStatus(OfflineEvent event) {
    DateTime now = DateTime.now();

    if (now.isBefore(event.dateTime)) {
      // Event is in the future
      Duration timeUntilStart = event.dateTime.difference(now);
      int days = timeUntilStart.inDays;
      int hours = timeUntilStart.inHours.remainder(24);
      int minutes = timeUntilStart.inMinutes.remainder(60);
      return 'Upcoming - Starts in ${days}d ${hours}h ${minutes}m';
    } else if (now.isAfter(event.dateTime)) {
      // Event is in the past
      return 'Past';
    } else {
      // If you consider "Ongoing" as the same day/time window, you can customize it here.
      // For demonstration, let's assume it's ongoing on the exact date/time.
      // You might want to define a different logic if the event is ongoing for multiple days/hours.
      return 'Ongoing';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reference to your Firestore collection
    final eventsRef = FirebaseFirestore.instance.collection('Offline-Events');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offline Mangrove Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to real-time updates from the 'Offline-Events' collection
        stream: eventsRef.snapshots(),
        builder: (context, snapshot) {
          // Show an error message if something goes wrong
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          // Show a loading indicator while Firestore connects
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Convert Firestore documents to a list of OfflineEvent
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No events available.'),
            );
          }

          final offlineEvents = docs.map((doc) {
            return OfflineEvent.fromDocument(doc);
          }).toList();

          // Build the UI with a ListView or any widget of your choice
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // You can show a banner or an image here
                Image.asset('assets/images/manevents.png', fit: BoxFit.cover),
                const SizedBox(height: 16.0),
                const Text(
                  'Mangrove Matters',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Participate in quests and workshops about mangrove ecology and earn exciting rewards!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Quests:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),

                // Display each event in a custom widget
                ...offlineEvents.map((event) {
                  final status = getEventStatus(event);
                  return Column(
                    children: [
                      _buildEventItem(context, event, status),
                      const SizedBox(height: 16.0),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// A helper widget that renders a single event's details.
  Widget _buildEventItem(BuildContext context, OfflineEvent event, String status) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(35.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event name
              Text(
                event.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Status (Upcoming, Past, Ongoing)
              Row(
                children: [
                  const Icon(Icons.timer),
                  const SizedBox(width: 8),
                  Text(status),
                ],
              ),
              const SizedBox(height: 8),
              // Location
              Row(
                children: [
                  const Icon(Icons.pin_drop),
                  const SizedBox(width: 8),
                  Text(event.location),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
