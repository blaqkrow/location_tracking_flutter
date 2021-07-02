import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TrackLocation extends StatefulWidget {
  @override
  _TrackLocationState createState() => _TrackLocationState();
}

class _TrackLocationState extends State<TrackLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Location Tracking'),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: start, child: Text('Start')
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: stop, child: Text('Stop')
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

    Position p = await Geolocator.getCurrentPosition();

    print('Lat: '+p.latitude.toString());
    print('Lng: '+p.longitude.toString());
  }

  void  stop() {
    print('stop tracking!');
  }
}