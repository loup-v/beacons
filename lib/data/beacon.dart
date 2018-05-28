//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class Beacon {
  Beacon._(
    this.ids,
    this.distance,
    this.rssi,
    this._platformCustoms,
  );

  final List<dynamic> ids;
  final double distance;
  final int rssi;
  final Map<String, dynamic> _platformCustoms;
}

class BeaconIBeacon {
  BeaconIBeacon.from(Beacon beacon)
      : proximityUUID = beacon.ids[0],
        major = beacon.ids.length > 1 ? beacon.ids[1] : null,
        minor = beacon.ids.length > 2 ? beacon.ids[2] : null,
        accuracy = beacon.distance,
        rssi = beacon.rssi,
        proximity =
            _JsonCodec.proximityFromJson(beacon._platformCustoms['proximity']);

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
