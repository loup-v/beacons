//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

import 'dart:async';

import 'package:beacons/beacons.dart';

import 'tab_base.dart';

class RangingTab extends ListTab {
  RangingTab() : super(title: 'Ranging');

  @override
  Stream<ListTabResult> stream(BeaconRegion region) {
    return Beacons
        .ranging(
      region: region,
      inBackground: false,
      permission: LocationPermission(android: LocationPermissionAndroid.coarse),
    )
        .map((result) {
      String text;
      if (result.isSuccessful == true) {
        text = result.beacons.isNotEmpty
            ? 'DISTANCE: ${result.beacons.first.distance.toStringAsFixed(2)}'
            : 'No beacon in range';
      } else {
        text = result.error.toString();
      }

      return new ListTabResult(text: text, isSuccessful: result.isSuccessful);
    });
  }
}
