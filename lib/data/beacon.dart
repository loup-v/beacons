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

enum MonitoringEvent { enter, exit }
