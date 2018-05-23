//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class _DataRequest {
  _DataRequest(
    this.region,
    this.permission,
    this.inBackground,
  );

  final BeaconRegion region;
  final LocationPermission permission;
  final bool inBackground;
}

class _StatusRequest {
  _StatusRequest(
    this.ranging,
    this.monitoring,
    this.permission,
  );

  final bool ranging;
  final bool monitoring;
  final LocationPermission permission;
}
