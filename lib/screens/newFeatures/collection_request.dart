import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {

  Future<List<Map<String, dynamic>>> _fetchRequests() async {
    final requestsQuery = await FirebaseFirestore.instance
        .collection('Submissions')
        .where('campaign_id', isEqualTo: 'Recycling')
        .where('status', isEqualTo: 'pending')
        .get();

      return requestsQuery.docs.map((doc) {
          final data = doc.data();
          return {
             'id': doc.id,
            ...data,
          };

       }).toList();
  }


  Future<void> _navigateToLocationScreen(String docId, String location) async {
      Position position = await _determinePosition();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LocationScreen(
            currentLocation: position,
            submissionLocation: location,
             docId: docId,
             onAccept: () {
               _acceptRequest(docId);
             },
            ),
        ));

  }


    Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }


   Future<void> _acceptRequest(String docId) async {
    // Update status to 'accepted' in Firestore
     try {
          await FirebaseFirestore.instance
        .collection('Submissions')
        .doc(docId)
        .update({'status': 'accepted'});

     Navigator.of(context).pop();


     }
    catch(e){
          print("error updating status: $e");
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
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
           if(snapshot.hasError){
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
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                 child: InkWell(
                  onTap: (){
                      _navigateToLocationScreen(request['id'], request['location']?.toString() ?? '');
                  },
                    child:Padding(
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
                                    request['location']?.toString() ?? '', // Add null check and default value
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  )
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class LocationScreen extends StatelessWidget {
  final Position currentLocation;
  final String submissionLocation;
    final String docId;
  final VoidCallback onAccept;

  const LocationScreen({super.key, required this.currentLocation, required this.submissionLocation, required this.docId, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: Center(
        child: Padding(
           padding: const EdgeInsets.all(16.0),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
           Text('Current Location: ${currentLocation.latitude}, ${currentLocation.longitude}'),
            Text('Submission Location: $submissionLocation'),
              const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                 _openMap();
              },
              child: const Text('Open Google Maps'),
            ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.green,
                                  foregroundColor: Colors.white
                      ),
                      onPressed: onAccept,
                      child: const Text('Accept'),
                    ),
                     ElevatedButton(
                         style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                  foregroundColor: Colors.white
                         ),
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


   Future<void> _openMap() async {
    final submissionLat = double.tryParse(submissionLocation.split(',').first);
    final submissionLong = double.tryParse(submissionLocation.split(',').last);

        if(submissionLat == null || submissionLong == null){
           String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$submissionLocation';
             try{
          await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
          }
           catch(e){
              print("error opening maps: $e");
            }
        }

       else{
          String googleUrl = 'https://www.google.com/maps/dir/?api=1&origin=${currentLocation.latitude},${currentLocation.longitude}&destination=$submissionLat,$submissionLong&travelmode=driving';
          try{
              await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
            }
           catch(e){
             print("error opening maps: $e");
            }
          }
    }
}