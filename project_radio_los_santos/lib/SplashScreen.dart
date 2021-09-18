import 'package:flutter/material.dart';
import 'package:project_radio_los_santos/Services/MyAudioHandler.dart';

import 'Services/AudioData.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required this.initDoneCallback})
      : super(key: key);
  final void Function() initDoneCallback;
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _initServices();
    super.initState();
  }

  void _initServices() async {
    await AudioData.initialize();
    await MyAudioHandler.initService();
    widget.initDoneCallback();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Radio Los Santos",
      theme: ThemeData(),
      home: Container(),
    );
  }
}
