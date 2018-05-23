//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class LocationPermission {
  const LocationPermission({
    this.android = LocationPermissionAndroid.coarse,
    this.ios = LocationPermissionIOS.whenInUse,
  });

  final LocationPermissionAndroid android;
  final LocationPermissionIOS ios;
}


/// iOS values for [LocationPermission].
///
/// Documentation: <https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services>
enum LocationPermissionIOS { whenInUse, always }


/// Android values for [LocationPermission].
///
/// Documentation: <https://developer.android.com/training/location/retrieve-current.html#permissions>
enum LocationPermissionAndroid { fine, coarse }