//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class _Channel {
  static const String _loggingTag = 'beacons';

  static const MethodChannel _channel = const MethodChannel('beacons');

  static final EventChannel _rangingChannel =
      new EventChannel('beacons/ranging');

  static final EventChannel _monitoringChannel =
      new EventChannel('beacons/monitoring');

  final _BridgeController<RangingResult> _rangingController =
      new _BridgeController<RangingResult>(
    'ranging',
    _channel,
    _rangingChannel,
    new _MethodController<_DataRequest>(
      'startRanging',
      (request) => _Codec.encodeDataRequest(request),
    ),
    new _MethodController<_DataRequest>(
      'stopRanging',
      (request) => request.region.identifier,
    ),
    (data) => _Codec.decodeRangingResult(data),
  );

  final _BridgeController<MonitoringResult> _monitoringController =
      new _BridgeController<MonitoringResult>(
    'monitoring',
    _channel,
    _monitoringChannel,
    new _MethodController<_DataRequest>(
      'startMonitoring',
      (request) => _Codec.encodeDataRequest(request),
    ),
    new _MethodController<_DataRequest>(
      'stopMonitoring',
      (request) => request.region.identifier,
    ),
    (data) => _Codec.decodeMonitoringResult(data),
  );

  Future<BeaconsResult> checkStatus(_StatusRequest request) async {
    final response = await _invokeChannelMethod(
      _loggingTag,
      _channel,
      'checkStatus',
      _Codec.encodeStatusRequest(request),
    );
    return _Codec.decodeResult(response);
  }

  Future<BeaconsResult> requestPermission(LocationPermission permission) async {
    final response = await _invokeChannelMethod(_loggingTag, _channel,
        'requestPermission', _Codec.encodePermission(permission));
    return _Codec.decodeResult(response);
  }

  Stream<RangingResult> ranging(_DataRequest request) {
    return _rangingController.listen(request);
  }

  Stream<MonitoringResult> monitoring(_DataRequest request) {
    return _monitoringController.listen(request);
  }
}

class _BridgeController<T extends BeaconsDataResult> {
  _BridgeController(
    this.tag,
    this.channel,
    this.eventChannel,
    this.startMethod,
    this.stopMethod,
    T decode(dynamic data),
  ) : stream = eventChannel.receiveBroadcastStream().map((data) {
          _log(data, tag: tag);
          return decode(data);
        });

  final String tag;
  final MethodChannel channel;
  final EventChannel eventChannel;
  final _MethodController<_DataRequest> startMethod;
  final _MethodController<_DataRequest> stopMethod;

  final Stream<T> stream;
  final List<_Bridge> bridges = [];

  Stream<T> listen(_DataRequest request) {
    // Reuse existing bridge for request with same identifier
    final _Bridge existing = bridges.singleWhere(
        (it) => it.identifier == request.region.identifier,
        orElse: () => null);
    if (existing != null) {
      return existing.clientController.stream;
    }

    _Bridge bridge;

    final StreamController<T> clientController =
        new StreamController<T>.broadcast(
      onListen: () async {
        _log('${startMethod.name} [id=${bridge.identifier}]', tag: tag);

        bridge.channelSubscription = stream.listen((T result) {
          // Forward channel stream location result to subscription
          if (result.region.identifier == bridge.identifier) {
            bridge.clientController.add(result);
          }
        });

        _invokeChannelMethod(
          tag,
          channel,
          startMethod.name,
          startMethod.encoder(request),
        );
      },
      onCancel: () {
        _log('${stopMethod.name} [id=${bridge.identifier}]', tag: tag);

        bridge.channelSubscription.cancel();
        bridge.clientController.close();
        bridges.remove(bridge);

        _invokeChannelMethod(
          tag,
          channel,
          stopMethod.name,
          stopMethod.encoder(request),
        );
      },
    );

    bridge = new _Bridge(request.region.identifier, clientController);
    bridges.add(bridge);

    return bridge.clientController.stream;
  }
}

// Bridge:
// - from the single event channel stream from platform side
// - to each individual stream created by the client on the Flutter side
class _Bridge<T> {
  _Bridge(
    this.identifier,
    this.clientController,
  );

  final String identifier;
  final StreamController<T> clientController;

  // ignore: cancel_subscriptions
  StreamSubscription<T> channelSubscription;
}

class _MethodController<T> {
  _MethodController(this.name, this.encoder);

  final String name;
  final _Encoder<T> encoder;
}

typedef dynamic _Encoder<T>(T t);
