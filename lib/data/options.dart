//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class MonitoringOptionsAndroid {
  const MonitoringOptionsAndroid([
    this.permission = LocationPermissionAndroid.coarse,
  ]);

  final LocationPermissionAndroid permission;
}
