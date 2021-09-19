import 'dart:math';

import 'package:flutter/material.dart';
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
  Sequence sequence =
      Sequence.buildCurrent(radioStation: AudioData.radioStations[0]);
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
                    var file = sequence.currentFileWithPointer;
                    debugPrint(
                        "${file.path} pointer=${Duration(milliseconds: file.pointer)} duration=${Duration(milliseconds: file.duration)}");
                  },
                  child: const Text("generate sequencen")),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    height: sequence.sequence[index].duration / 500 + 0.0,
                    color: Colors.red
                        .withOpacity(0.25 + Random().nextDouble() * 0.75),
                    child: FittedBox(
                      child: Text(sequence.sequence[index].path),
                    ),
                  );
                },
                itemCount: sequence.sequence.length,
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
