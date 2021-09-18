import 'package:flutter/material.dart';
import 'package:project_radio_los_santos/Screens/player_screen.dart';
import 'package:project_radio_los_santos/SplashScreen.dart';

void main() {
  runApp(const SplashScreen(initDoneCallback: mainApp));
}

void mainApp() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Los Santos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlayerScreen(),
    );
  }
}
