import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  bool _isLoading = false;
  late Position _currentPosition;
  String _filter = 'pending';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Submissions')
        .where('campaign_id', isEqualTo: 'Recycling');

    if (_filter == 'pending') {
      query = query.where('status', isEqualTo: 'pending');
    } else if (_filter == 'accepted') {
      query = query
          .where('status', isEqualTo: 'accepted')
          .where('accepted_by', isEqualTo: user.email);
    }

    final requestsQuery = await query.get();

    return requestsQuery.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  Future<void> _navigateToLocationScreen(String docId, String location, Map<String, dynamic>? locations) async {
    setState(() {
      _isLoading = true;
    });
    try {
      Position position = await _determinePosition();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LocationScreen(
          currentLocation: position,
          submissionLocation: location,
          submissionLocations: locations,
          docId: docId,
          onAccept: () {
            _acceptRequest(docId);
          },
            isAccepted: _filter == 'accepted',
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

  Future<void> _acceptRequest(String docId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      await FirebaseFirestore.instance
          .collection('Submissions')
          .doc(docId)
          .update({'status': 'accepted', 'accepted_by': user.email});

      Navigator.of(context).pop();
    } catch (e) {
      print("Error accepting request: $e");
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
        title: const Text('Requests'),
        actions: [
          DropdownButton<String>(
            value: _filter,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _filter = newValue;
                });
              }
            },
            items: const [
              DropdownMenuItem(
                value: 'pending',
                child: Text('Pending Requests'),
              ),
              DropdownMenuItem(
                value: 'accepted',
                child: Text('Accepted Requests'),
              ),
            ],
          )
        ],
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
                          _navigateToLocationScreen(
                            request['id'],
                            request['location']?.toString() ?? '',
                            request['locations'] as Map<String, dynamic>?,
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

class LocationScreen extends StatefulWidget {
  final Position currentLocation;
  final String submissionLocation;
  final String docId;
  final Map<String, dynamic>? submissionLocations;
  final VoidCallback onAccept;
    final bool isAccepted;

  const LocationScreen(
      {super.key,
      required this.currentLocation,
      required this.submissionLocation,
      required this.docId,
      required this.onAccept,
       this.submissionLocations,
        this.isAccepted = false,
      });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  LatLng? _submissionLocationCoords;

  void initState() {
    super.initState();
    _extractCoordinates();
  }

  Future<void> _extractCoordinates() async {
    final submissionLat =
        double.tryParse(widget.submissionLocation.split(',').first);
    final submissionLong =
        double.tryParse(widget.submissionLocation.split(',').last);

    if (submissionLat != null && submissionLong != null) {
      setState(() {
        _submissionLocationCoords = LatLng(submissionLat, submissionLong);
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.submissionLocations?['latitude'];
    final lng = widget.submissionLocations?['longitude'];
    String locationImage;
    if (lat != null && lng != null) {
      locationImage =
          'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyDo4_5HApr0g6HOQ8NNqJhgG67jxu-ycYE';
    } else {
      locationImage = '';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (locationImage.isNotEmpty)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    locationImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Could not load image.',
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              Text('Submission Location: ${widget.submissionLocation}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _openMap(widget.currentLocation, widget.submissionLocation,
                      lat, lng);
                },
                child: const Text('Open Google Maps'),
              ),
              const SizedBox(height: 20),
              if (!widget.isAccepted)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                    onPressed: widget.onAccept,
                    child: const Text('Accept'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Decline'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMap(Position currentLocation, String submissionLocation,
      double? submissionLat, double? submissionLong) async {
    if (submissionLat == null || submissionLong == null) {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$submissionLocation';
      try {
        await launchUrl(Uri.parse(googleUrl),
            mode: LaunchMode.externalApplication);
      } catch (e) {
        print("error opening maps: $e");
      }
    } else {
      String googleUrl =
          'https://www.google.com/maps/dir/?api=1&origin=${currentLocation.latitude},${currentLocation.longitude}&destination=$submissionLat,$submissionLong&travelmode=driving';
      try {
        await launchUrl(Uri.parse(googleUrl),
            mode: LaunchMode.externalApplication);
      } catch (e) {
        print("error opening maps: $e");
      }
    }
  }
}