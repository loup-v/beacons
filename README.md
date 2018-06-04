# Beacons

[![pub package](https://img.shields.io/pub/v/beacons.svg)](https://pub.dartlang.org/packages/beacons)

[Flutter plugin](https://pub.dartlang.org/packages/beacons/) to work with beacons.  
Supports Android API 16+ and iOS 8+.  

Features:

* Automatic permission management
* Ranging
* Monitoring (including background)


Supported beacons specifications:

* iBeacon (iOS & Android)
* Altbeacon (Android)


## Installation

Add to pubspec.yaml:

```yaml
dependencies:
  beacons: ^0.3.0
```

**Note:** The plugin is written in Swift for iOS.  
There is a known issue for integrating swift plugin into Flutter project using the Objective-C template. Follow the instructions from [Flutter#16049](https://github.com/flutter/flutter/issues/16049) to resolve the issue (Cocoapods 1.5+ is mandatory).


### Setup specific for Android

Create a subclass of `FlutterApplication`:

```kotlin
class App : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()

        // Beacons setup for Android
        BeaconsPlugin.init(this, object : BeaconsPlugin.BackgroundMonitoringCallback {
            override fun onBackgroundMonitoringEvent(event: BackgroundMonitoringEvent): Boolean {
                val intent = Intent(this@App, MainActivity::class.java)
                startActivity(intent)
                return true
            }
        })
    }
}
```

And register it in `android/app/src/main/AndroidManifest.xml`:

```xmln
<manifest ...>
  ...
  <application
    android:name=".App"
    android:label="beacons_example"
    android:icon="@mipmap/ic_launcher">
    ...
  </application>
</manifest>
```

`BeaconsPlugin.BackgroundMonitoringCallback` is required to react to background monitoring events. The callback will be executed when a monitoring event is detected while the app is running in background. In the snipped above, it will start the Flutter app. It will also allow to receive a callback on the Flutter side. See background monitoring section for more details.

For permission, see below.

### Setup specific for iOS

Nothing. Contrary to the general opinion, you do not need to enable any background mode.

For permission, see below.


### Permission

In order to use beacons related features, apps are required to ask the location permission. It's a two step process:

1. Declare the permission the app requires in configuration files
2. Request the permission to the user when app is running (the plugin can handle this automatically)

#### For iOS

There are two available permissions in iOS: `when in use` and `always`.  
The latter is required for background monitoring.

For more details about what you can do with each permission, see:  
https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services

Permission must be declared in `ios/Runner/Info.plist`:

```xml
<dict>
  <!-- When in use -->
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Reason why app needs location</string>

  <!-- Always -->
  <!-- for iOS 11 + -->
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>Reason why app needs location</string>
  <!-- for iOS 9/10 -->
  <key>NSLocationAlwaysUsageDescription</key>
  <string>Reason why app needs location</string>
  ...
</dict>
```

#### For Android

There are two available permissions in Android: `coarse` and `fine`.  
For beacons related features, there are no difference between the two permission.

Permission must be declared in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <!-- or -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
</manifest>
```

## How-to

Ranging and monitoring APIs are designed as reactive streams.  

* The first subscription to the stream will start the ranging/monitoring ;
* The last cancelling (when there are no more subscription) on the stream will stop the ranging/monitoring operation.

### Ranging beacons

```dart
Beacons.ranging(
  region: new BeaconRegionIBeacon(
    identifier: 'test',
    proximityUUID: '7da11b71-6f6a-4b6d-81c0-8abd031e6113',
  ),
  inBackground: false, // continue the ranging operation in background or not, see below
).listen((result) {
  // result contains a list of beacons
  // list can be empty if no matching beacons were found in range
}
```

#### Background ranging

When turned off, ranging will automatically pause when app goes to background and resume when app comes back to foreground. Otherwise it will actively continue in background until the app is terminated by the OS.

Ranging beacons while the app is terminated is not supported by the OS. For this kind of usage, see background monitoring.

### Monitoring beacons

```dart
Beacons.monitoring(
  region: new BeaconRegionIBeacon(
    identifier: 'test',
    proximityUUID: '7da11b71-6f6a-4b6d-81c0-8abd031e6113',
  ),
  inBackground: false, // continue the monitoring operation in background or not, see below
).listen((result) {
  // result contains the new monitoring state:
  // - enter
  // - exit
}
```

#### Background monitoring

When turned off, monitoring will automatically pause when app goes to background and resume when app comes back to foreground. Otherwise it will actively continue in background until the app is terminated by the OS.

Once the app has been terminated, the monitoring will continue.  
If a monitoring event happens, the OS will start the app in background for several seconds (nothing will be visible for the user). The OS is providing you the opportunity to perform some quick operation, like showing a local notification.

In order to listen to background monitoring events, you can subscribe to a special  stream. This stream is passive: it does not start a monitoring operation. You are still required to start it using `Beacons.monitoring(inBackground: true)`.

Because the OS will run the app in background for several seconds only, before terminating it again, the good place to setup the listener is during app startup.

```dart
class MyApp extends StatefulWidget {
  MyApp() {
    Beacons.backgroundMonitoringEvents().listen((event) {
      final BackgroundMonitoringEventType type = event.type // didEnterRegion, didExitRegion or didDetermineState
      final BeaconRegion region = event.region // The monitored region associated to the event
      final MonitoringState state = event.state // useful for type = didDetermineState

      // do something quick here to react to the background monitoring event, like showing a notification
    });
  }

  @override
  _MyAppState createState() => new _MyAppState();
}
```

For testing background monitoring and what result you should expect, read:  
https://developer.radiusnetworks.com/2013/11/13/ibeacon-monitoring-in-the-background-and-foreground.html

Alternatively to starting/stoping monitoring using `Beacons.monitoring()` stream subscription, you can use the following imperative API:

```dart
// Result will be successful if monitoring has started, or contain the reason why it has not (permission denied, etc)
final BeaconsResult result = await Beacons.startMonitoring(
  region: BeaconRegionIBeacon(
    identifier: 'test',
    proximityUUID: 'uuid',
  ),
  inBackground: true,
);

await Beacons.stopMonitoring(
  region: BeaconRegionIBeacon(
    identifier: 'test',
    proximityUUID: 'uuid',
  ),
);
```

Note that these functions can only start/stop the monitoring.  
To receive the associated monitoring events, listen to the stream from `Beacons.backgroundMonitoringEvents()`.

### Beacons types

For every API that requires or return a region or a beacon, you can work with the different types of beacons specs.

Regardless of the beacons specs, each region requires an unique identifier that are used by the engine under the hood to uniquely identify and manage a ranging/monitoring request.

#### Generic

```dart
Beacons.ranging(region: BeaconRegion(
    identifier: 'test',
    ids: ['id1', 'id2', 'id3'],
  ),
).listen((result) {
  final Beacon beacon = result.beacons.first;
});
```

#### iBeacon

```dart
Beacons.ranging(region: BeaconRegionIBeacon(
    identifier: 'test',
    proximityUUID: 'some-uuid',
    major:0,
    minor: 0,
  ),
).listen((result) {
  final BeaconIBeacon beacon = BeaconIBeacon.from(result.beacons.first);
});
```



## Under the hood

* iOS uses native iOS CoreLocation
* Android uses the third-party library [android-beacon-library](https://github.com/AltBeacon/android-beacon-library) (Apache License 2.0)

Each technology has its own specificities.  
The plugin does its best to abstract it and expose a common logic, but for an advanced usage, you would probably still need to familiarize yourself with the native technology.


## Sponsor

Beacons plugin development is sponsored by [Pointz](https://www.pointz.io/), a startup that rewards people for spending time at local, brick and mortar businesses. [Pointz](https://www.pointz.io/) is proudly based in Birmingham, AL.


## Author

Beacons plugin is developed by Loup, a mobile development studio based in Montreal and Paris.  
You can contact us at <hello@intheloup.io>


## License

Apache License 2.0
