//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class BeaconsResult {
  BeaconsResult._(
    this.isSuccessful,
    this.error,
  ) {
    assert(isSuccessful != null);
    assert(isSuccessful || error != null);
  }

  final bool isSuccessful;
  final BeaconsResultError error;

  String dataToString() {
    return "without additional data";
  }

  @override
  String toString() {
    if (isSuccessful) {
      return '{success: ${dataToString()} }';
    } else {
      return '{failure: $error }';
    }
  }
}

abstract class BeaconsDataResult {
  BeaconRegion get region;
}

class RangingResult extends BeaconsResult implements BeaconsDataResult {
  RangingResult._(
      bool isSuccessful, BeaconsResultError error, this.region, this.beacons)
      : super._(isSuccessful, error);

  @override
  final BeaconRegion region;
  final List<Beacon> beacons;

  bool get isEmpty => beacons.isEmpty;

  bool get isNotEmpty => beacons.isNotEmpty;

  @override
  String dataToString() {
    return "${beacons.length} for region: ${region.identifier}";
  }
}

class MonitoringResult extends BeaconsResult implements BeaconsDataResult {
  MonitoringResult._(
    bool isSuccessful,
    BeaconsResultError error,
    this.region,
    this.event,
  ) : super._(isSuccessful, error);

  @override
  final BeaconRegion region;
  final MonitoringEvent event;

  @override
  String dataToString() {
    return "$event for region: ${region.identifier}";
  }
}

class BeaconsResultError {
  BeaconsResultError._(
    this.type,
    this.message,
    this.additionalInfo,
  );

  final BeaconsResultErrorType type;
  final String message;
  final dynamic additionalInfo;

  @override
  String toString() {
    switch (type) {
      case BeaconsResultErrorType.runtime:
        return 'unknown';
      case BeaconsResultErrorType.permissionDenied:
        return 'permission denied';
      case BeaconsResultErrorType.serviceDisabled:
        return 'service disabled';
      case BeaconsResultErrorType.rangingUnavailable:
        return 'ranging unavailable';
      case BeaconsResultErrorType.monitoringUnavailable:
        return 'monitoring unavailable';
      case BeaconsResultErrorType.playServicesUnavailable:
        return 'play services -> $additionalInfo';
    }

    assert(false);
    return null;
  }
}

enum BeaconsResultErrorType {
  runtime,
  permissionDenied,
  serviceDisabled,
  rangingUnavailable,
  monitoringUnavailable,
  playServicesUnavailable,
}

BeaconsResultErrorType _mapResultErrorTypeJson(String jsonValue) {
  switch (jsonValue) {
    case 'runtime':
      return BeaconsResultErrorType.runtime;
    case 'permissionDenied':
      return BeaconsResultErrorType.permissionDenied;
    case 'serviceDisabled':
      return BeaconsResultErrorType.serviceDisabled;
    case 'rangingUnavailable':
      return BeaconsResultErrorType.rangingUnavailable;
    case 'monitoringUnavailable':
      return BeaconsResultErrorType.monitoringUnavailable;
    case 'playServicesUnavailable':
      return BeaconsResultErrorType.playServicesUnavailable;
    default:
      assert(false, 'cannot parse json to BeaconsResultErrorType: $jsonValue');
      return null;
  }
}
