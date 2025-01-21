import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:renewa/models/place.dart';

class LocationInput extends StatefulWidget {
  final Function(PlaceLocation) onSelectPlace;

  const LocationInput({super.key, required this.onSelectPlace});

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyDo4_5HApr0g6HOQ8NNqJhgG67jxu-ycYE';
  }

  void _getcurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Check if service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    try {
      locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;

      if (lat == null || lng == null) {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyDo4_5HApr0g6HOQ8NNqJhgG67jxu-ycYE');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      final resData = json.decode(response.body);

      if (resData['status'] == 'REQUEST_DENIED') {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      if (resData['results'].isEmpty) {
        setState(() {
          _pickedLocation = PlaceLocation(
              latitude: lat, longitude: lng, address: 'No address found');
          _isGettingLocation = false;
        });
        widget.onSelectPlace(_pickedLocation!);
        return;
      }

      final address = resData['results'][0]['formatted_address'];

      setState(() {
        _pickedLocation =
            PlaceLocation(latitude: lat, longitude: lng, address: address);
        _isGettingLocation = false;
      });
      widget.onSelectPlace(_pickedLocation!);
    } catch (error) {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onSurface),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            'Could not load image.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          );
        },
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: _getcurrentLocation,
            ),
          ],
        ),
      ],
    );
  }
}
