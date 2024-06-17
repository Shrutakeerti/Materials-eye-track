import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seeso_flutter/seeso.dart';
import 'package:seeso_flutter/seeso_initialized_result.dart';
import 'package:seeso_flutter/event/gaze_info.dart';
import 'package:seeso_flutter/seeso_plugin_constants.dart';

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _seesoPlugin = SeeSo();
  static const String _licenseKey =
      "_licenseKey"; // todo: input your license key
  double _x = 0.0, _y = 0.0;
  bool _hasCameraPermission = false;
  MaterialColor _gazeColor = Colors.red;

  @override
  void initState() {
    super.initState();
    initSeeSo();
  }

  Future<void> checkCameraPermission() async {
    _hasCameraPermission = await _seesoPlugin.checkCameraPermission();
    if (!_hasCameraPermission) {
      _hasCameraPermission = await _seesoPlugin.requestCameraPermission();
    }
    if (!mounted) {
      return;
    }
  }

  Future<void> initSeeSo() async {
    await checkCameraPermission();
    if (_hasCameraPermission) {
      try {
        InitializedResult? initializedResult =
            await _seesoPlugin.initGazeTracker(licenseKey: _licenseKey);
        if (initializedResult!.result) {
          listenEvents();
          try {
            _seesoPlugin.startTracking();
          } on PlatformException catch (e) {
            print("Occur PlatformException (${e.message})");
          }
        }
      } on PlatformException catch (e) {
        print("Occur PlatformException (${e.message})");
      }
    }
  }

  void listenEvents() {
    _seesoPlugin.getGazeEvent().listen((event) {
      GazeInfo info = GazeInfo(event);

      if (info.trackingState == TrackingState.SUCCESS) {
        setState(() {
          _x = info.x;
          _y = info.y;
          _gazeColor = Colors.green;
        });
      } else {
        setState(() {
          _gazeColor = Colors.red;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: null, // Hide the AppBar
            body: Stack(children: <Widget>[
              Positioned(
                  left: _x - 5,
                  top: _y - 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _gazeColor,
                      shape: BoxShape.circle,
                    ),
                  )),
            ])));
  }
}
