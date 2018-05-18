//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class _RangingRequest {
  _RangingRequest(
    this.region,
    this.permission,
    this.inBackground,
  );

  int id;
  final BeaconRegion region;
  final LocationPermission permission;
  final bool inBackground;
}
