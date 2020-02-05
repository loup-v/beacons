//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

library beacons;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'stream_channel.dart';

part 'channel/channels.dart';

part 'channel/codec.dart';

part 'channel/helper.dart';

part 'channel/param.dart';

part 'data/beacon.dart';

part 'data/beacon_region.dart';

part 'data/monitoring.dart';

part 'data/permission.dart';

part 'data/request.dart';

part 'data/result.dart';

part 'data/settings.dart';

class Beacons {
  static Future<void> configure(BeaconsSettings settings) =>
      _channel.configure(settings);

  static Future<BeaconsResult> checkStatus({
    bool ranging = true,
    bool monitoring = true,
    LocationPermission permission = const LocationPermission(),
  }) =>
      _channel.checkStatus(new _StatusRequest(
        ranging,
        monitoring,
        permission,
      ));

  static Future<BeaconsResult> requestPermission([
    LocationPermission permission = const LocationPermission(),
  ]) =>
      _channel.requestPermission(permission);

  static Stream<RangingResult> ranging({
    @required BeaconRegion region,
    bool inBackground = false,
    LocationPermission permission = const LocationPermission(),
  }) =>
      _channel.ranging(new _DataRequest(
        region,
        permission,
        inBackground,
      ));

  static Stream<MonitoringResult> monitoring({
    @required BeaconRegion region,
    @required bool inBackground,
    LocationPermission permission = const LocationPermission(
      ios: LocationPermissionIOS.always,
    ),
  }) {
    assert(permission.ios == LocationPermissionIOS.always);
    return _channel.monitoring(new _DataRequest(
      region,
      permission,
      inBackground,
    ));
  }

  static Future<BeaconsResult> startMonitoring({
    @required BeaconRegion region,
    @required bool inBackground,
    LocationPermission permission = const LocationPermission(
      ios: LocationPermissionIOS.always,
    ),
  }) {
    assert(permission.ios == LocationPermissionIOS.always);
    return _channel.startMonitoring(new _DataRequest(
      region,
      permission,
      inBackground,
    ));
  }

  static Future<void> stopMonitoring(BeaconRegion region) {
    return _channel.stopMonitoring(region);
  }

  static Stream<BackgroundMonitoringEvent> backgroundMonitoringEvents() {
    return _channel.backgroundMonitoringEvents();
  }

  /// Activate verbose logging for debugging purposes.
  static bool loggingEnabled = false;

  static final _Channels _channel = new _Channels();
}

class BeaconsException implements Exception {
  BeaconsException(this.message);

  final String message;

  @override
  String toString() {
    return 'Beacons error: $message';
  }
}

_log(String message, {String tag}) {
  if (Beacons.loggingEnabled) {
    debugPrint(tag != null ? '$tag: $message' : message);
  }
}
