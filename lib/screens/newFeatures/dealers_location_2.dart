import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DealerLocationScreen extends StatefulWidget {
  final Position currentLocation;
  final String submissionLocation;
  final Map<String, dynamic>? submissionLocations;
  final String docId;

  const DealerLocationScreen(
      {super.key,
      required this.currentLocation,
      required this.submissionLocation,
      this.submissionLocations,
      required this.docId});

  @override
  State<DealerLocationScreen> createState() => _DealerLocationScreenState();
}

class _DealerLocationScreenState extends State<DealerLocationScreen> {
  late GoogleMapController mapController;
  LatLng? _submissionLocationCoords;

  @override
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
      appBar: AppBar(title: const Text('Dealer Location')),
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
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Could not load image.',
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              Text('Dealer Location: ${widget.submissionLocation}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _openMap(lat, lng);
                },
                child: const Text('Open Google Maps'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMap(double? submissionLat, double? submissionLong) async {
    if (submissionLat == null || submissionLong == null) {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=${widget.submissionLocation}';
      try {
        await launchUrl(Uri.parse(googleUrl),
            mode: LaunchMode.externalApplication);
      } catch (e) {
        print("error opening maps: $e");
      }
    } else {
      String googleUrl =
          'https://www.google.com/maps/dir/?api=1&origin=${widget.currentLocation.latitude},${widget.currentLocation.longitude}&destination=$submissionLat,$submissionLong&travelmode=driving';
      try {
        await launchUrl(Uri.parse(googleUrl),
            mode: LaunchMode.externalApplication);
      } catch (e) {
        print("error opening maps: $e");
      }
    }
  }
}
