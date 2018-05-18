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
      case BeaconsResultErrorType.notFound:
        return 'not found';
      case BeaconsResultErrorType.permissionDenied:
        return 'permission denied';
      case BeaconsResultErrorType.serviceDisabled:
        return 'service disabled';
      case BeaconsResultErrorType.rangingUnavailable:
        return 'ranging unavailable';
      case BeaconsResultErrorType.playServicesUnavailable:
        return 'play services -> $additionalInfo';
      default:
        assert(false);
        return null;
    }
  }
}

enum BeaconsResultErrorType {
  runtime,
  notFound,
  permissionDenied,
  serviceDisabled,
  rangingUnavailable,
  playServicesUnavailable,
}

BeaconsResultErrorType _mapResultErrorTypeJson(String jsonValue) {
  switch (jsonValue) {
    case 'runtime':
      return BeaconsResultErrorType.runtime;
    case 'notFound':
      return BeaconsResultErrorType.notFound;
    case 'permissionDenied':
      return BeaconsResultErrorType.permissionDenied;
    case 'serviceDisabled':
      return BeaconsResultErrorType.serviceDisabled;
    case 'rangingUnavailable':
      return BeaconsResultErrorType.rangingUnavailable;
    case 'playServicesUnavailable':
      return BeaconsResultErrorType.playServicesUnavailable;
    default:
      assert(
          false, 'cannot parse json to GeolocationResultErrorType: $jsonValue');
      return null;
  }
}
