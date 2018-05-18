//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

library beacons;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'channel/channel.dart';
part 'channel/codec.dart';
part 'channel/helper.dart';
part 'channel/param.dart';
part 'data/beacon.dart';
part 'data/beacon_region.dart';
part 'data/permission.dart';
part 'data/ranging_result.dart';
part 'data/result.dart';
part 'facet_ios/permission.dart';

class Beacons {
  static Future<BeaconsResult> isRangingOperational({
    LocationPermission permission = const LocationPermission(),
  }) =>
      _beaconsChannel.isRangingOperational(permission);

  static Future<BeaconsResult> requestLocationPermission([
    LocationPermission permission = const LocationPermission(),
  ]) =>
      _beaconsChannel.requestLocationPermission(permission);

  static Stream<RangingResult> rangingUpdates({
    @required BeaconRegion region,
    bool inBackground = false,
    LocationPermission permission = const LocationPermission(),
  }) =>
      _beaconsChannel.rangingUpdates(new _RangingRequest(
        region,
        permission,
        inBackground,
      ));

  /// Activate verbose logging for debugging purposes.
  static bool loggingEnabled = false;

  static final _BeaconsChannel _beaconsChannel = new _BeaconsChannel();
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
