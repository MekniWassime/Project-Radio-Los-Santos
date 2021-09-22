import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/AudioFileWithPointer.dart';
import 'package:project_radio_los_santos/Models/Sequence.dart';
import 'package:project_radio_los_santos/Services/AudioData.dart';
import 'package:project_radio_los_santos/Services/MyAudioHandler.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  //late AudioPlayer player;
  //bool loading = true;
  late Sequence sequence;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    MyAudioHandler.instance.play();
    sequence = Sequence.buildCurrent(radioStation: AudioData.radioStations[0]);
    //AudioFileWithPointer current = sequence.currentFileWithPointer;
    //var audioSource = AudioSource.uri(
    //  Uri.parse("asset:///${current.path}"),
    //   tag: const MediaItem(
    //    id: '1',
    //   album: "Album name",
    //    title: "Song name",
    //  ),
    // );
    //player = AudioPlayer();
    //await player.setAudioSource(audioSource);
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
                    //player.play();
                    MyAudioHandler.instance.play();
                    //var file = sequence.currentFileWithPointer;
                    //debugPrint(
                    //    "${file.path} pointer=${Duration(milliseconds: file.pointer)} duration=${Duration(milliseconds: file.duration)}");
                  },
                  child: const Text("generate sequencen")),
              ElevatedButton(
                  onPressed: () {
                    //player.play();
                    //MyAudioHandler.instance.play();
                    Sequence.buildCurrent(
                        radioStation: AudioData.radioStations[0]);
                  },
                  child: const Text("print sequance stats")),
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
