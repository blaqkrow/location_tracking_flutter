import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TrackLocation extends StatefulWidget {
  
  @override
  _TrackLocationState createState() => _TrackLocationState();
}

class _TrackLocationState extends State<TrackLocation> {

  var timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Location Tracking'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 30),
            TextButton(
              onPressed: start, child: Text('Start Trip')
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: stop, child: Text('End Trip')
            ),
          ],
        ),
      )
    );
  }

  void start() async {
    print('start tracking!');
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
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    int count = 0;
    CollectionReference locations = FirebaseFirestore.instance.collection('locations');

    timer = Timer.periodic(Duration(milliseconds: 5000), (timer) async { 
      Position p = await Geolocator.getCurrentPosition();
      count++;
      print(count);

      await locations.add({
        'lat': p.latitude,
        'lng': p.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });

      print('Lat: '+p.latitude.toString());
      print('Lng: '+p.longitude.toString());
    });

  }

  void  stop() {
    timer.cancel();
    print('stop tracking!');
  }
}