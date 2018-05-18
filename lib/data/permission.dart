//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class LocationPermission {
  const LocationPermission({
    this.ios = LocationPermissionIOS.whenInUse,
  });

  final LocationPermissionIOS ios;
}
