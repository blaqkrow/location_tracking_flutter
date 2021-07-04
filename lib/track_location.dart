import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:background_location/background_location.dart';


class TrackLocation extends StatefulWidget {
  @override
  _TrackLocationState createState() => _TrackLocationState();
}

class _TrackLocationState extends State<TrackLocation> {
  var timer; 
  List<Widget> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Location Tracking'),
      ),
      body: ListView(
          reverse: true,
          children: [
            SizedBox(height: 30),
            TextButton(
              onPressed: start, child: Text('Start Trip')
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: stop, child: Text('End Trip')
            ),

            Column(
              children: messages,
            )
          ],
      )
    );
  }

  /*
    * Starts the location service and background location service.
    * Periodically sends location every 60 seconds to firestore collection 'locations'.
    * @return      void
  */
  void start() async {
    int count = 0; //tracks how many mins have elapsed
    print('start tracking!');
    bool serviceEnabled;
    LocationPermission permission;

    //initialised geolocator location permissions
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

    //Used background_location to create a background location routine https://pub.dev/packages/background_location/versions/0.5.0
    BackgroundLocation.setAndroidConfiguration(60000);
    await BackgroundLocation.startLocationService();
    //BackgroundLocation doesnt fire periodically on iOS for some reason, used Timer.periodic as a workaround to fire 
    BackgroundLocation.getLocationUpdates((location) {
      print('in background location');
      timer = Timer.periodic(Duration(seconds: 60), (timer) async { 
        count++;
        //hacky, not sure why callback executes 3 times upon timer tick
        if(count % 3 == 0) {
          print("Getting location... count: "+ count.toString());

          double minutesElapsed = count / 3; //get total number of minutes which has elapsed
          Position p = await Geolocator.getCurrentPosition(); //get current geo position

          print(p.latitude); //print lat long
          print(p.longitude);
          String m = minutesElapsed.toInt().toString() + ' minute has elapsed - Lat: '+p.latitude.toString() + ', Lng: '+p.longitude.toString();
          setState(() {
            messages.add(Text(m)); // push log message into list
          });

          //Create a firestore reference and store coordinates on firebase with timestamp
          CollectionReference locations = FirebaseFirestore.instance.collection('locations');
          await locations.add({
            'lat': p.latitude,
            'lng': p.longitude,
            'timestamp': DateTime.now().millisecondsSinceEpoch
          });

        }
      });
    });
  }

  /*
    * Stops BackgroundLocation service and stops the timer.
    * @return      void
  */
  void stop() {
    BackgroundLocation.stopLocationService();
    timer.cancel();
    print('stop tracking!');
  }
}