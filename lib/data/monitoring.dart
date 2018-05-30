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
    this.name,
    this.region,
    this.state,
  );

  final String name;
  final BeaconRegion region;
  final MonitoringState state;
}
