import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:renewa/screens/newFeatures/dealer_award_2.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  bool _isLoading = false;
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  Future<List<Map<String, dynamic>>> _fetchRequests() async {
    final requestsQuery = await FirebaseFirestore.instance
        .collection('Submissions')
        .where('campaign_id', isEqualTo: 'Recycling')
        .where('status', isEqualTo: 'accepted')
        .get();

    List<Map<String, dynamic>> requests = [];

    for (var doc in requestsQuery.docs) {
      final data = doc.data();
      requests.add({
        'id': doc.id,
        'title': data['title'],
        'location': data['location'],
        'locations': data['locations'],
        'photo_url': data['photo_url'],
        'accepted_by': data['accepted_by'],
        'user_email': data['user_email']
      });
    }

    return requests;
  }

  Future<void> _navigateToSubmissionDetails(
      String docId,
      String location,
      Map<String, dynamic>? locations,
      String photoUrl,
      String acceptedBy,
      String userEmail) async {
    setState(() {
      _isLoading = true;
    });
    try {
      Position position = await _determinePosition();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SubmissionDetailsScreen(
          currentLocation: position,
          submissionLocation: location,
          submissionLocations: locations,
          docId: docId,
          photoUrl: photoUrl,
          acceptedBy: acceptedBy,
          userEmail: userEmail,
        ),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
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
        title: const Text('Requests'),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                print("Error: ${snapshot.error}");
                return const Center(child: Text('Error fetching requests'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No requests found'));
              }
              final requests = snapshot.data!;
              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Card(
                    color: Colors.black,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: InkWell(
                        onTap: () {
                          _navigateToSubmissionDetails(
                            request['id'],
                            request['location']?.toString() ?? '',
                            request['locations'] as Map<String, dynamic>?,
                            request['photo_url']?.toString() ?? '',
                            request['accepted_by']?.toString() ?? '',
                            request['user_email']?.toString() ?? '',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request['title'] ?? 'Report',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      request['location']?.toString() ?? '',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }
}
