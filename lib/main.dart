import 'package:flutter/material.dart';
import 'package:location_tracking_flutter/track_location.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Location Tracking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrackLocation(),
    );
  }
}
