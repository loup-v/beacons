import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class StreamsChannel {
  StreamsChannel(this.name, [this.codec = const StandardMethodCodec()]);

  /// The logical channel on which communication happens, not null.
  final String name;

  /// The message codec used by this channel, not null.
  final MethodCodec codec;

  int _lastId = 0;

  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    final MethodChannel methodChannel = new MethodChannel(name, codec);

    final id = ++_lastId;
    final handlerName = '$name#$id';

    StreamController<dynamic> controller;
    controller = new StreamController<dynamic>.broadcast(onListen: () async {
      ServicesBinding.instance.defaultBinaryMessenger
          .setMessageHandler(handlerName, (ByteData reply) async {
        if (reply == null) {
          controller.close();
        } else {
          try {
            controller.add(codec.decodeEnvelope(reply));
          } on PlatformException catch (e) {
            controller.addError(e);
          }
        }

        return reply;
      });
      try {
        await methodChannel.invokeMethod('listen#$id', arguments);
      } catch (exception, stack) {
        FlutterError.reportError(new FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'streams_channel',
          context: DiagnosticsNode.message(
              'while activating platform stream on channel $name'),
        ));
      }
    }, onCancel: () async {
      ServicesBinding.instance.defaultBinaryMessenger
          .setMessageHandler(handlerName, null);
      try {
        await methodChannel.invokeMethod('cancel#$id', arguments);
      } catch (exception, stack) {
        FlutterError.reportError(new FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'streams_channel',
          context: DiagnosticsNode.message(
              'while de-activating platform stream on channel $name'),
        ));
      }
    });
    return controller.stream;
  }
}
