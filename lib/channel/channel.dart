//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

part of beacons;

class _BeaconsChannel {
  static const MethodChannel _channel = const MethodChannel('beacons');

  static final _CustomEventChannel _rangingUpdatesChannel =
      new _CustomEventChannel('beacons/rangingUpdates');

  static const String _loggingTag = 'beacons result';

  List<_RangingSubscription> _rangingSubscriptions = [];

  Future<BeaconsResult> isRangingOperational(
      LocationPermission permission) async {
    final response = await _invokeChannelMethod(_loggingTag, _channel,
        'isRangingOperational', _Codec.encodeLocationPermission(permission));
    return _Codec.decodeResult(response);
  }

  Future<BeaconsResult> requestLocationPermission(
      LocationPermission permission) async {
    final response = await _invokeChannelMethod(
        _loggingTag,
        _channel,
        'requestLocationPermission',
        _Codec.encodeLocationPermission(permission));
    return _Codec.decodeResult(response);
  }

  Stream<RangingResult> rangingUpdates(_RangingRequest request) {
    // The stream that will be returned for the current location request
    StreamController<RangingResult> controller;

    _RangingSubscription subscriptionWithRequest;

    // Subscribe and listen to channel stream of location results
    // ignore: cancel_subscriptions
    final StreamSubscription<RangingResult> subscription =
        _rangingUpdatesChannel.stream.map((data) {
      _log(data, tag: _loggingTag);
      return _Codec.decodeRangingResult(data);
    }).listen((RangingResult result) {
      // Forward channel stream location result to subscription
      if (result.region.identifier == request.region.identifier) {
        controller.add(result);
      }
    });

    subscription.onDone(() {
      _rangingSubscriptions.remove(subscriptionWithRequest);
    });

    subscriptionWithRequest = new _RangingSubscription(request, subscription);

    // Add unique id for each request, in order to be able to remove them on platform side afterwards
    subscriptionWithRequest.request.id = (_rangingSubscriptions.isNotEmpty
            ? _rangingSubscriptions.map((it) => it.request.id).reduce(math.max)
            : 0) +
        1;

    _log('create location updates request [id=${subscriptionWithRequest
        .request
        .id}]');
    _rangingSubscriptions.add(subscriptionWithRequest);

    controller = new StreamController<RangingResult>.broadcast(
      onListen: () {
        _log('add ranging request [id=${subscriptionWithRequest.request
            .id}]');
        _invokeChannelMethod(_loggingTag, _channel, 'startRangingRequest',
            _Codec.encodeRangingRequest(request));
      },
      onCancel: () async {
        _log('remove ranging request [id=${subscriptionWithRequest
            .request
            .id}]');
        subscriptionWithRequest.subscription.cancel();

        await _invokeChannelMethod(_loggingTag, _channel, 'stopRangingRequest',
            _Codec.encodeRangingRequest(request));
        _rangingSubscriptions.remove(subscriptionWithRequest);
      },
    );

    return controller.stream;
  }
}

class _RangingSubscription {
  _RangingSubscription(this.request, this.subscription);

  final _RangingRequest request;
  final StreamSubscription<BeaconsResult> subscription;
}

// Custom event channel that manages a single instance of the stream and exposes.
class _CustomEventChannel extends EventChannel {
  _CustomEventChannel(name, [codec = const StandardMethodCodec()])
      : super(name, codec);

  Stream<dynamic> _stream;

  Stream<dynamic> get stream {
    if (_stream == null) {
      _stream = receiveBroadcastStream();
    }
    return _stream;
  }

  @override
  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    final MethodChannel methodChannel = new MethodChannel(name, codec);
    StreamController<dynamic> controller;
    controller = new StreamController<dynamic>.broadcast(onListen: () async {
      BinaryMessages.setMessageHandler(name, (ByteData reply) async {
        if (reply == null) {
          controller.close();
        } else {
          try {
            controller.add(codec.decodeEnvelope(reply));
          } on PlatformException catch (e) {
            controller.addError(e);
          }
        }
      });
      try {
        await methodChannel.invokeMethod('listen', arguments);
      } catch (exception, stack) {
        FlutterError.reportError(new FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context: 'while activating platform stream on channel $name',
        ));
      }
    }, onCancel: () async {
      BinaryMessages.setMessageHandler(name, null);
      try {
        await methodChannel.invokeMethod('cancel', arguments);
      } catch (exception, stack) {
        FlutterError.reportError(new FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context: 'while de-activating platform stream on channel $name',
        ));
      }
    });

    return controller.stream;
  }
}
