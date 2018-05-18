//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class BeaconRegion {
  BeaconRegion({
    @required this.proximityUUID,
    @required this.identifier,
    this.major,
    this.minor,
  });

  final String proximityUUID;

  final String identifier;

  final int major;

  final int minor;
}
