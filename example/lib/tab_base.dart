//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

import 'dart:async';

import 'package:beacons/beacons.dart';
import 'package:beacons_example/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class ListTab extends StatefulWidget {
  const ListTab({Key key, this.title}) : super(key: key);

  final String title;

  Stream<ListTabResult> stream(BeaconRegion region);

  @override
  _ListTabState createState() => new _ListTabState();
}

class ListTabData {}

class _ListTabState extends State<ListTab> {
  List<ListTabResult> _results = [];
  StreamSubscription<ListTabResult> _subscription;
  int _subscriptionStartedTimestamp;
  bool _running = false;

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  void _onStart(BeaconRegion region) {
    setState(() {
      _running = true;
    });

    _subscriptionStartedTimestamp = new DateTime.now().millisecondsSinceEpoch;
    _subscription = widget.stream(region).listen((result) {
      result.elapsedTimeSeconds = (new DateTime.now().millisecondsSinceEpoch -
              _subscriptionStartedTimestamp) ~/
          1000;

      setState(() {
        _results.insert(0, result);
      });
    });

    _subscription.onDone(() {
      setState(() {
        _running = false;
      });
    });
  }

  void _onStop() {
    setState(() {
      _running = false;
    });

    _subscription.cancel();
    _subscriptionStartedTimestamp = null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
        children: <Widget>[
          new Header(
            regionIdentifier: 'test',
            running: _running,
            onStart: _onStart,
            onStop: _onStop,
          ),
          new Expanded(
            child: new ListView(
              children: ListTile
                  .divideTiles(
                    context: context,
                    tiles: _results
                        .map((location) => new _Item(result: location))
                        .toList(),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  _Item({@required this.result});

  final ListTabResult result;

  @override
  Widget build(BuildContext context) {
    final String text = result.text;
    final String status = result.isSuccessful ? 'success' : 'failure';
    final Color color = result.isSuccessful ? Colors.green : Colors.red;

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
        'Elapsed time: ${result.elapsedTimeSeconds == 0 ? '< 1' : result
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

class ListTabResult {
  ListTabResult({
    @required this.text,
    @required this.isSuccessful,
  });

  final String text;
  final bool isSuccessful;
  int elapsedTimeSeconds;
}
