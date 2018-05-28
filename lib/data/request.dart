//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class BeaconRegionRequest {
  BeaconRegionRequest({this.android, this.iOS}) {
    assert(android != null || iOS != null);

    // do not allow different identifier for each platform
    // it does not make sense and could result in subtle bugs for the end user
    assert((android == null || iOS == null) ||
        android.identifier == iOS.identifier);
  }

  final BeaconRegion android;
  final BeaconRegionIBeacon iOS;
}