//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

import 'dart:async';

import 'package:beacons/beacons.dart';

import 'tab_base.dart';

class MonitoringTab extends ListTab {
  MonitoringTab() : super(title: 'Monitoring');

  @override
  Stream<ListTabResult> stream(BeaconRegion region) {
    return Beacons
        .monitoring(
      region: region,
      inBackground: true,
    )
        .map((result) {
      String text;
      if (result.isSuccessful) {
        text = result.event.toString();
      } else {
        text = result.error.toString();
      }

      return new ListTabResult(text: text, isSuccessful: result.isSuccessful);
    });
  }
}
