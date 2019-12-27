import 'package:flutter/material.dart';
import 'package:beacons/beacons.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  scanBeacons() {
    Beacons.ranging(
      region: BeaconRegion(identifier: ""),
    ).listen((data) {
      print(data.beacons);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          child: Text("Scan"),
          onPressed: scanBeacons,
        ),
      ),
    );
  }
}
