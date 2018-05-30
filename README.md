# Beacons

[![pub package](https://img.shields.io/pub/v/beacons.svg)](https://pub.dartlang.org/packages/beacons)

Flutter [beacons plugin](https://pub.dartlang.org/packages/beacons/) for Android API 16+ and iOS 9+.  

Features:

* Automatic permission management
* Ranging
* Monitoring

Supported beacons:

* iOS: iBeacon
* Android: iBeacon and Alt-Beacon


## Installation

Add beacons to your pubspec.yaml:

```yaml
dependencies:
  beacons: ^0.2.0
```

**Note:** There is a known issue for integrating swift written plugin into Flutter project created with Objective-C template.
See issue [Flutter#16049](https://github.com/flutter/flutter/issues/16049) for help on integration.


### Permission

Android and iOS require to declare the location permission in a configuration file.

#### For iOS

There are two kinds of location permission available in iOS: "when in use" and "always".

If you don't know what permission to choose for your usage, see:
https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services

You need to declare the description for the desired permission in `ios/Runner/Info.plist`:

```xml
<dict>
  <!-- for iOS 11 + -->
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Reason why app needs location</string>
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>Reason why app needs location</string>

  <!-- additionally for iOS 9/10, if you need always permission -->
  <key>NSLocationAlwaysUsageDescription</key>
  <string>Reason why app needs location</string>
  ...
</dict>
```


#### For Android

There are two kinds of location permission in Android: "coarse" and "fine".  
You need to declare one of the two permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <!-- or -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
</manifest>
```


## Getting started

### Ranging beacons

```dart
Beacons.ranging(
  region: new BeaconRegionIBeacon(
    identifier: 'test',
    proximityUUID: '7da11b71-6f6a-4b6d-81c0-8abd031e6113',
  ),
  inBackground: false,
).listen((result) {
  debugPrint('result = $result');
}
```

### Monitoring beacons

```dart
Beacons.monitoring(
  region: new BeaconRegionIBeacon(
    identifier: 'test',
    proximityUUID: '7da11b71-6f6a-4b6d-81c0-8abd031e6113',
  ),
  inBackground: false,
).listen((result) {
  debugPrint('result = $result');
}
```

### Background monitoring

```dart
class MyApp extends StatefulWidget {
  MyApp() {
    Beacons.loggingEnabled = true;

    Beacons.backgroundMonitoringEvents().listen((event) {
      // Event can be didEnterRegion, didExitRegion, didDetermineState.
      // This code is executed in background (app is not visible to the user),
      // it's a good place to show a local notification for instance (see example project).
    });
  }

  @override
  _MyAppState createState() => new _MyAppState();
}
```

## Under the hood

* iOS side uses native CoreLocation SDK
* Android side uses [android-beacon-library](https://github.com/AltBeacon/android-beacon-library)


## Sponsor

Beacons plugin development is sponsored by [Pointz](https://www.pointz.io/)


## Author

Beacons plugin is developed by Loup, a mobile development studio based in Montreal and Paris.  
You can contact us at <hello@intheloup.io>


## License

Apache License 2.0
