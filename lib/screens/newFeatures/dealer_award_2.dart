import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:renewa/screens/newFeatures/dealer_award_3.dart';

class SubmissionDetailsScreen extends StatelessWidget {
  final Position currentLocation;
  final String submissionLocation;
  final Map<String, dynamic>? submissionLocations;
  final String docId;
  final String photoUrl;
  final String acceptedBy;
  final String userEmail;

  const SubmissionDetailsScreen({
    super.key,
    required this.currentLocation,
    required this.submissionLocation,
    this.submissionLocations,
    required this.docId,
    required this.photoUrl,
    required this.acceptedBy,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final lat = submissionLocations?['latitude'];
    final lng = submissionLocations?['longitude'];
    String locationImage;
    if (lat != null && lng != null) {
      locationImage =
          'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=YOUR_API_KEY';
    } else {
      locationImage = '';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Submission Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (locationImage.isNotEmpty)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    locationImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Could not load image.',
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              Text('Submission Location: $submissionLocation'),
              const SizedBox(height: 10),
              if (photoUrl.isNotEmpty)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Could not load image.',
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
              Text('Accepted by: $acceptedBy'),
              const SizedBox(height: 10),
              Text('Submitted by : $userEmail'),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RewardScreen(
                          docId: docId,
                          submissionLocations: submissionLocations,
                          acceptedBy: acceptedBy,
                          userEmail: userEmail),
                    ));
                  },
                  child: const Text('Reward'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
