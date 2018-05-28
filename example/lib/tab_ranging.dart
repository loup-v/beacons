//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

import 'dart:async';

import 'package:beacons/beacons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TabRanging extends StatefulWidget {
  @override
  _TabRangingState createState() => new _TabRangingState();
}

class _TabRangingState extends State<TabRanging> {
  List<_Data> _locations = [];
  StreamSubscription<RangingResult> _subscription;
  int _subscriptionStartedTimestamp;
  bool _isTracking = false;

  @override
  dispose() {
    super.dispose();
    _subscription.cancel();
  }

  _onTogglePressed() {
    if (_isTracking) {
      setState(() {
        _isTracking = false;
      });

      _subscription.cancel();
      _subscription = null;
      _subscriptionStartedTimestamp = null;
    } else {
      setState(() {
        _isTracking = true;
      });

      _subscriptionStartedTimestamp = new DateTime.now().millisecondsSinceEpoch;
      _subscription = Beacons
          .ranging(
        region: new BeaconRegionIBeacon(
          identifier: 'test',
          proximityUUID: '7da11b71-6f6a-4b6d-81c0-8abd031e6113',
        ),
        inBackground: false,
      )
          .listen((result) {
        debugPrint('result = $result');
        final location = new _Data(
          result: result,
          elapsedTimeSeconds: (new DateTime.now().millisecondsSinceEpoch -
                  _subscriptionStartedTimestamp) ~/
              1000,
        );

        setState(() {
          _locations.insert(0, location);
        });
      });

      _subscription.onDone(() {
        setState(() {
          _isTracking = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      new _Header(
        isRunning: _isTracking,
        onTogglePressed: _onTogglePressed,
      )
    ];

    children.addAll(ListTile.divideTiles(
      context: context,
      tiles: _locations.map((location) => new _Item(data: location)).toList(),
    ));

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Ranging'),
      ),
      body: new ListView(
        children: children,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  _Header({@required this.isRunning, this.onTogglePressed});

  final bool isRunning;
  final VoidCallback onTogglePressed;

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: new Center(
        child: new _HeaderButton(
          title: isRunning ? 'Stop' : 'Start',
          color: isRunning ? Colors.deepOrange : Colors.teal,
          onTap: onTogglePressed,
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  _HeaderButton(
      {@required this.title, @required this.color, @required this.onTap});

  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: new GestureDetector(
        onTap: onTap,
        child: new Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
          decoration: new BoxDecoration(
            color: color,
            borderRadius: new BorderRadius.all(
              new Radius.circular(6.0),
            ),
          ),
          child: new Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  _Item({@required this.data});

  final _Data data;

  @override
  Widget build(BuildContext context) {
    String text;
    String status;
    Color color;

    if (data.result.isSuccessful) {
      text = data.result.isNotEmpty
          ? 'RSSI: ${data.result.beacons.first.rssi}'
          : 'No beacon in range';
      status = 'success';
      color = Colors.green;
    } else {
      switch (data.result.error.type) {
        case BeaconsResultErrorType.runtime:
          text = 'Failure: ${data.result.error.message}';
          break;
        case BeaconsResultErrorType.serviceDisabled:
          text = 'Service disabled';
          break;
        case BeaconsResultErrorType.rangingUnavailable:
          text = 'Ranging unavailable';
          break;
        case BeaconsResultErrorType.monitoringUnavailable:
          text = 'Monitoring unavailable';
          break;
        case BeaconsResultErrorType.permissionDenied:
          text = 'Permission denied';
          break;
      }

      status = 'failure';
      color = Colors.red;
    }

    final List<Widget> content = <Widget>[
      new Text(
        text,
        style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      new SizedBox(
        height: 3.0,
      ),
      new Text(
        'Elapsed time: ${data.elapsedTimeSeconds == 0 ? '< 1' : data
            .elapsedTimeSeconds}s',
        style: const TextStyle(fontSize: 12.0, color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ];

    return new Container(
      color: Colors.white,
      child: new SizedBox(
        height: 56.0,
        child: new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content,
                ),
              ),
              new Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: new BoxDecoration(
                  color: color,
                  borderRadius: new BorderRadius.circular(6.0),
                ),
                child: new Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Data {
  _Data({
    @required this.result,
    @required this.elapsedTimeSeconds,
  });

  final RangingResult result;
  final int elapsedTimeSeconds;
}
