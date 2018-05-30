//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

import 'dart:io';

import 'package:beacons/beacons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Header extends StatefulWidget {
  const Header(
      {Key key, this.regionIdentifier, this.running, this.onStart, this.onStop})
      : super(key: key);

  final String regionIdentifier;
  final bool running;
  final ValueChanged<BeaconRegion> onStart;
  final VoidCallback onStop;

  @override
  _HeaderState createState() => new _HeaderState();
}

class _HeaderState extends State<Header> {
  FormType _formType;
  TextEditingController _id1Controller;
  TextEditingController _id2Controller;
  TextEditingController _id3Controller;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _formType = Platform.isIOS ? FormType.iBeacon : FormType.generic;

    _id1Controller = TextEditingController(
      text: _formType == FormType.iBeacon
          ? '7da11b71-6f6a-4b6d-81c0-8abd031e6113'
          : '',
    );
    _id2Controller = TextEditingController();
    _id3Controller = TextEditingController();
  }

  void _onFormTypeChanged(FormType value) {
    setState(() {
      _formType = value;
    });
  }

  void _onTapSubmit() {
    if (widget.running) {
      widget.onStop();
    } else {
      if (!_formKey.currentState.validate()) {
        return;
      }
      List<dynamic> ids = [];
      if (_id1Controller.value.text.isNotEmpty) {
        ids.add(_id1Controller.value.text);

        if (_id2Controller.value.text.isNotEmpty) {
          ids.add(_id2Controller.value.text);

          if (_id3Controller.value.text.isNotEmpty) {
            ids.add(_id3Controller.value.text);
          }
        }
      }
      BeaconRegion region =
          BeaconRegion(identifier: widget.regionIdentifier, ids: ids);

      // ignore: missing_enum_constant_in_switch
      switch (_formType) {
        case FormType.iBeacon:
          region = BeaconRegionIBeacon.from(region);
          break;
      }

      widget.onStart(region);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: new Text(
                'Beacon format',
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
          new Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new Flexible(
                  child: new RadioListTile(
                value: FormType.generic,
                groupValue: _formType,
                onChanged: widget.running
                    ? null
                    : (Platform.isAndroid ? _onFormTypeChanged : null),
                title: new Text(Platform.isAndroid
                    ? 'Generic'
                    : 'Generic (not supported on iOS)'),
              )),
              new Flexible(
                  child: new RadioListTile(
                value: FormType.iBeacon,
                groupValue: _formType,
                onChanged: widget.running ? null : _onFormTypeChanged,
                title: const Text('iBeacon'),
              )),
            ],
          ),
          new Form(
            key: _formKey,
            child: _formType == FormType.generic
                ? new _FormGeneric(
                    running: widget.running,
                    id1Controller: _id1Controller,
                    id2Controller: _id2Controller,
                    id3Controller: _id3Controller,
                  )
                : new _FormIBeacon(
                    running: widget.running,
                    id1Controller: _id1Controller,
                    id2Controller: _id2Controller,
                    id3Controller: _id3Controller,
                  ),
          ),
          new SizedBox(
            height: 10.0,
          ),
          new _Button(
            running: widget.running,
            onTap: _onTapSubmit,
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  _Button({
    @required this.running,
    @required this.onTap,
  });

  final bool running;
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
            color: running ? Colors.deepOrange : Colors.teal,
            borderRadius: new BorderRadius.all(
              new Radius.circular(6.0),
            ),
          ),
          child: new Text(
            running ? 'Stop' : 'Start',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

enum FormType { generic, iBeacon }

class _TextFieldDecoration extends InputDecoration {
  const _TextFieldDecoration()
      : super(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
          border: const OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(5.0),
            ),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
        );
}

class _FormGeneric extends StatelessWidget {
  const _FormGeneric(
      {Key key,
      this.running,
      this.id1Controller,
      this.id2Controller,
      this.id3Controller})
      : super(key: key);

  final bool running;
  final TextEditingController id1Controller;
  final TextEditingController id2Controller;
  final TextEditingController id3Controller;

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new TextFormField(
          enabled: !running,
          controller: id1Controller,
          decoration: const _TextFieldDecoration()
              .copyWith(hintText: 'Id 1 (optional)'),
        ),
        new SizedBox(
          height: 10.0,
        ),
        new TextFormField(
          enabled: !running,
          controller: id2Controller,
          decoration: const _TextFieldDecoration()
              .copyWith(hintText: 'Id 2 (optional)'),
        ),
        new SizedBox(
          height: 10.0,
        ),
        new TextFormField(
          enabled: !running,
          controller: id3Controller,
          decoration: const _TextFieldDecoration()
              .copyWith(hintText: 'Id 3 (optional)'),
        ),
        new SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}

class _FormIBeacon extends StatelessWidget {
  const _FormIBeacon(
      {Key key,
      this.running,
      this.id1Controller,
      this.id2Controller,
      this.id3Controller})
      : super(key: key);

  final bool running;
  final TextEditingController id1Controller;
  final TextEditingController id2Controller;
  final TextEditingController id3Controller;

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new TextFormField(
          enabled: !running,
          validator: (String value) {
            if (value.isEmpty) {
              return 'required';
            }
          },
          controller: id1Controller,
          decoration: const _TextFieldDecoration().copyWith(hintText: 'UDID'),
        ),
        new SizedBox(
          height: 10.0,
        ),
        new Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Flexible(
              child: new TextFormField(
                enabled: !running,
                controller: id2Controller,
                decoration: const _TextFieldDecoration()
                    .copyWith(hintText: 'Major (optional)'),
              ),
            ),
            new SizedBox(
              width: 10.0,
            ),
            new Flexible(
              child: new TextFormField(
                enabled: !running,
                controller: id3Controller,
                decoration: const _TextFieldDecoration()
                    .copyWith(hintText: 'Minor (optional)'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
