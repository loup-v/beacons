//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class Beacon {
  Beacon._(
    this.proximityUUID,
    this.major,
    this.minor,
    this.accuracy,
    this.rssi,
    this.proximity,
  );

  final String proximityUUID;

  final int major;

  final int minor;

  final double accuracy;

  final int rssi;

  final BeaconProximity proximity;
}

enum BeaconProximity {
  unknown,
  immediate,
  near,
  far,
}
