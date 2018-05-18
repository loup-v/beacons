//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class RangingResult extends BeaconsResult {
  RangingResult._(
      bool isSuccessful, BeaconsResultError error, this.region, this.beacons)
      : super._(isSuccessful, error);

  final BeaconRegion region;
  final List<Beacon> beacons;
}
