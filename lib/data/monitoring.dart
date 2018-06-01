//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

enum MonitoringState {
  enterOrInside,
  exitOrOutside,
  unknown,
}

class BackgroundMonitoringEvent {
  BackgroundMonitoringEvent._(
    this.type,
    this.region,
    this.state,
  );

  final BackgroundMonitoringEventType type;
  final BeaconRegion region;
  final MonitoringState state;
}

enum BackgroundMonitoringEventType {
  didEnterRegion,
  didExitRegion,
  didDetermineState,
}

//class MonitoringOptionsAndroid {
//  const MonitoringOptionsAndroid([
//    this.permission = LocationPermissionAndroid.coarse,
//  ]);
//
//  final LocationPermissionAndroid permission;
//}
