//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class BeaconRegion {
  BeaconRegion({
    @required this.identifier,
    this.ids = const [],
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
    String major,
    String minor,
  }) : super(
          identifier: identifier,
          ids: [],
        ) {
    ids.add(proximityUUID);
    if (major != null) {
      ids.add(major);
    }
    if (minor != null) {
      ids.add(minor);
    }
  }

  BeaconRegionIBeacon.from(BeaconRegion region)
      : this(
          identifier: region.identifier,
          proximityUUID: region.ids[0],
          major: region.ids.length > 1 ? region.ids[1] : null,
          minor: region.ids.length > 2 ? region.ids[2] : null,
        );

  String get proximityUUID => ids[0];

  String get major => ids.length > 1 ? ids[1] : null;

  String get minor => ids.length > 2 ? ids[2] : null;
}
