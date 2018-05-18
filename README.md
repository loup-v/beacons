# Beacons

[![pub package](https://img.shields.io/pub/v/beacons.svg)](https://pub.dartlang.org/packages/beacons)

Flutter [beacons plugin](https://pub.dartlang.org/packages/beacons/) for Android API 16+ and iOS 9+.  

Features:

* Manual and automatic location permission management
* Beacons ranging

The plugin is under active development, only iOS is supported at that time.  
Public API might change once the Android side is integrated.


## Installation

Add beacons to your pubspec.yaml:

```yaml
dependencies:
  beacons: ^0.1.0
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



## Sponsor

Beacons plugin development is sponsored by [Pointz](https://www.pointz.io/)


## Author

Beacons plugin is developed by Loup, a mobile development studio based in Montreal and Paris.  
You can contact us at <hello@intheloup.io>


## License

Apache License 2.0
