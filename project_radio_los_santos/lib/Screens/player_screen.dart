import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/PlayableSong.dart';
import 'package:project_radio_los_santos/Models/Sequence.dart';
import 'package:project_radio_los_santos/Services/AudioData.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  //late AudioPlayer player;
  //bool loading = true;
  Sequence sequence = Sequence(AudioData.radioStations[0]);
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    /*player = AudioPlayer();
    await player
        .setAsset("assets/audio/Adverts/Zebra Bar 1 (What about nuts).ogg");
    loading = false;*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top, left: 10, right: 10),
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () {
                    debugPrint(sequence.toString());
                  },
                  child: Text("print sequence")),
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Color color;
                  if (sequence.playabelSequence[index] is PlayableSong)
                    color = Colors.red;
                  else
                    color = Colors.black;
                  return Container(
                      height: sequence.playabelSequence[index].duration / 1000 +
                          0.0,
                      color: color
                          .withOpacity(0.25 + Random().nextDouble() * 0.75));
                },
                itemCount: sequence.playabelSequence.length,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    //player.dispose();
    super.dispose();
  }
}
