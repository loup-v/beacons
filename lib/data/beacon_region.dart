//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class BeaconRegion {
  BeaconRegion({
    @required this.identifier,
    this.ids,
    this.bluetoothAddress,
  });

  final String identifier;
  final List<dynamic> ids;
  final String bluetoothAddress;
}

class BeaconRegionIBeacon extends BeaconRegion {
  BeaconRegionIBeacon({
    @required String identifier,
    @required String proximityUUID,
    int major,
    int minor,
  }) : super(
          identifier: identifier,
          ids: new List<String>(),
        ) {
    ids.add(proximityUUID);
    if (major != null) {
      ids.add(major.toString());
    }
    if (minor != null) {
      ids.add(minor.toString());
    }
  }

  BeaconRegionIBeacon._(BeaconRegion beacon)
      : this(
          identifier: beacon.identifier,
          proximityUUID: beacon.ids[0],
          major: beacon.ids.length > 1 ? beacon.ids[1] : null,
          minor: beacon.ids.length > 2 ? beacon.ids[2] : null,
        );

  String get proximityUUID => ids[0];

  int get major => ids.length > 1 ? ids[1] : null;

  int get minor => ids.length > 2 ? ids[2] : null;
}
