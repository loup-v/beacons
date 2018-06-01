//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class BeaconsSettings {
  const BeaconsSettings({
    this.android = const BeaconsSettingsAndroid(),
    this.iOS = const BeaconsSettingsIOS(),
  });

  final BeaconsSettingsAndroid android;
  final BeaconsSettingsIOS iOS;
}

class BeaconsSettingsAndroid {
  const BeaconsSettingsAndroid({
    this.logs = BeaconsSettingsAndroidLogs.empty,
  });

  final BeaconsSettingsAndroidLogs logs;
}

enum BeaconsSettingsAndroidLogs {
  empty,
  verbose,
  info,
  warning,
}

class BeaconsSettingsIOS {
  const BeaconsSettingsIOS();
}