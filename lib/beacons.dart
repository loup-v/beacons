//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

library beacons;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

part 'channel/channel.dart';
part 'channel/codec.dart';
part 'channel/helper.dart';
part 'channel/param.dart';
part 'data/beacon.dart';
part 'data/options.dart';
part 'data/permission.dart';
part 'data/result.dart';

class Beacons {
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
    bool inBackground = false,
    androidOptions = const MonitoringOptionsAndroid(),
  }) =>
      _channel.monitoring(new _DataRequest(
        region,
        new LocationPermission(
          android: androidOptions.permission,
          ios: LocationPermissionIOS.always,
        ),
        inBackground,
      ));

  /// Activate verbose logging for debugging purposes.
  static bool loggingEnabled = false;

  static final _Channel _channel = new _Channel();
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
