//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class _Codec {
  static BeaconsResult decodeResult(String data) =>
      _JsonCodec.resultFromJson(json.decode(data));

  static RangingResult decodeRangingResult(String data) =>
      _JsonCodec.rangingResultFromJson(json.decode(data));

  static MonitoringResult decodeMonitoringResult(String data) =>
      _JsonCodec.monitoringResultFromJson(json.decode(data));

  static BackgroundMonitoringEvent decodeBackgroundMonitoringEvent(
          String data) =>
      _JsonCodec.backgroundMonitoringEventFromJson(json.decode(data));

  static String encodePermission(LocationPermission permission) =>
      platformSpecific(
        android: _Codec.encodeEnum(permission.android),
        ios: _Codec.encodeEnum(permission.ios),
      );

  static String encodeSettings(BeaconsSettings settings) => platformSpecific(
        android:
            json.encode(_JsonCodec.settingsAndroidToJson(settings.android)),
        ios: json.encode(_JsonCodec.settingsIOSToJson(settings.iOS)),
      );

  static String encodeStatusRequest(_StatusRequest request) =>
      json.encode(_JsonCodec.statusRequestToJson(request));

  static String encodeDataRequest(_DataRequest request) =>
      json.encode(_JsonCodec.dataRequestToJson(request));

  static String encodeRegion(BeaconRegion region) =>
      json.encode(_JsonCodec.regionToJson(region));

  static String encodeEnum(dynamic value) {
    return value.toString().split('.').last;
  }

  // see: https://stackoverflow.com/questions/49611724/dart-how-to-json-decode-0-as-double
  static double parseJsonNumber(dynamic value) {
    return value.runtimeType == int ? (value as int).toDouble() : value;
  }

  static String platformSpecific({
    @required String android,
    @required String ios,
  }) {
    if (Platform.isAndroid) {
      return android;
    } else if (Platform.isIOS) {
      return ios;
    } else {
      throw new BeaconsException(
          'Unsupported platform: ${Platform.operatingSystem}');
    }
  }
}

class _JsonCodec {
  static BeaconsResult resultFromJson(Map<String, dynamic> json) =>
      new BeaconsResult._(
        json['isSuccessful'],
        json['error'] != null ? resultErrorFromJson(json['error']) : null,
      );

  static BeaconsResultError resultErrorFromJson(Map<String, dynamic> json) {
    final BeaconsResultErrorType type = _mapResultErrorTypeJson(json['type']);

    final BeaconsResultError error = new BeaconsResultError._(
      type,
      json['message'],
      null,
    );

    if (json.containsKey('fatal') && json['fatal']) {
      throw new BeaconsException(error.message);
    }

    return error;
  }

  static RangingResult rangingResultFromJson(Map<String, dynamic> json) =>
      new RangingResult._(
        json['isSuccessful'],
        json['error'] != null ? resultErrorFromJson(json['error']) : null,
        json['region'] != null ? beaconRegionFromJson(json['region']) : null,
        json['data'] != null
            ? (json['data'] as List<dynamic>)
                .map((it) => beaconFromJson(it as Map<String, dynamic>))
                .toList()
            : null,
      );

  static MonitoringResult monitoringResultFromJson(Map<String, dynamic> json) =>
      new MonitoringResult._(
        json['isSuccessful'],
        json['error'] != null ? resultErrorFromJson(json['error']) : null,
        json['region'] != null ? beaconRegionFromJson(json['region']) : null,
        json['data'] != null ? monitoringStateFromJson(json['data']) : null,
      );

  static BackgroundMonitoringEvent backgroundMonitoringEventFromJson(
          Map<String, dynamic> json) =>
      new BackgroundMonitoringEvent._(
        backgroundMonitoringEventTypeFromJson(json['type']),
        beaconRegionFromJson(json['region']),
        monitoringStateFromJson(json['state']),
      );

  static Beacon beaconFromJson(Map<String, dynamic> json) => new Beacon._(
      json['ids'],
      _Codec.parseJsonNumber(json['distance']),
      json['rssi'],
      json['platformCustoms']);

  static BeaconRegion beaconRegionFromJson(Map<String, dynamic> json) =>
      new BeaconRegion(
        identifier: json['identifier'],
        ids: json['ids'],
        bluetoothAddress: json['bluetoothAddress'],
      );

  static BeaconProximity proximityFromJson(String jsonValue) {
    switch (jsonValue) {
      case 'unknown':
        return BeaconProximity.unknown;
      case 'immediate':
        return BeaconProximity.immediate;
      case 'near':
        return BeaconProximity.near;
      case 'far':
        return BeaconProximity.far;
      default:
        assert(false, 'cannot parse json to BeaconProximity: $jsonValue');
        return null;
    }
  }

  static BackgroundMonitoringEventType backgroundMonitoringEventTypeFromJson(
      String jsonValue) {
    switch (jsonValue) {
      case 'didEnterRegion':
        return BackgroundMonitoringEventType.didEnterRegion;
      case 'didExitRegion':
        return BackgroundMonitoringEventType.didExitRegion;
      case 'didDetermineState':
        return BackgroundMonitoringEventType.didDetermineState;
      default:
        assert(false,
            'cannot parse json to BackgroundMonitoringEventType: $jsonValue');
        return null;
    }
  }

  static MonitoringState monitoringStateFromJson(String jsonValue) {
    switch (jsonValue) {
      case 'enterOrInside':
        return MonitoringState.enterOrInside;
      case 'exitOrOutside':
        return MonitoringState.exitOrOutside;
      case 'unknown':
        return MonitoringState.unknown;
      default:
        assert(false, 'cannot parse json to MonitoringState: $jsonValue');
        return null;
    }
  }

  static Map<String, dynamic> settingsAndroidToJson(
          BeaconsSettingsAndroid settings) =>
      {
        'logs': _Codec.encodeEnum(settings.logs),
      };

  static Map<String, dynamic> settingsIOSToJson(BeaconsSettingsIOS settings) =>
      {};

  static Map<String, dynamic> statusRequestToJson(_StatusRequest request) => {
        'ranging': request.ranging,
        'monitoring': request.monitoring,
        'permission': _Codec.encodePermission(request.permission),
      };

  static Map<String, dynamic> dataRequestToJson(_DataRequest request) => {
        'region': regionToJson(request.region),
        'permission': _Codec.encodePermission(request.permission),
        'inBackground': request.inBackground,
      };

  static Map<String, dynamic> regionToJson(BeaconRegion region) => {
        'identifier': region.identifier,
        'ids': region.ids,
        'bluetoothAddress': region.bluetoothAddress,
      };
}
