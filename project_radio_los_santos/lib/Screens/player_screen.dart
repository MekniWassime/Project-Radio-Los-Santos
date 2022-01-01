import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:project_radio_los_santos/Models/Sequence.dart';
import 'package:project_radio_los_santos/Services/MyAudioHandler.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  //late AudioPlayer player;
  //bool loading = true;
  Stream<Sequence> sequenceStream = MyAudioHandler.instance.sequenceStream;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    MyAudioHandler.instance.play();
    //sequence = Sequence.buildCurrent(radioStation: AudioData.radioStations[0]);
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
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        MyAudioHandler.instance.skipToPrevious();
                      },
                      icon: const Icon(
                        Icons.skip_previous,
                        size: 40,
                      )),
                  StreamBuilder<PlaybackState>(
                      stream: MyAudioHandler.instance.playbackState.stream,
                      builder: (context, snapshot) {
                        return IconButton(
                            onPressed: () {
                              if (snapshot.data?.playing ?? true)
                                MyAudioHandler.instance.pause();
                              else
                                MyAudioHandler.instance.play();
                            },
                            icon: Icon(
                              snapshot.data?.playing ?? true
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 40,
                            ));
                      }),
                  IconButton(
                      onPressed: () {
                        MyAudioHandler.instance.skipToNext();
                      },
                      icon: const Icon(
                        Icons.skip_next,
                        size: 40,
                      )),
                ],
              ),
              const SizedBox(height: 50),
              StreamBuilder<Sequence>(
                  initialData: MyAudioHandler.instance.currentSequence,
                  stream: sequenceStream,
                  builder: (context, snapshot) {
                    var sequence = snapshot.data;
                    debugPrint(sequence.toString());
                    if (sequence == null) return Container();
                    return Column(
                      children: [
                        Text(sequence.radioStation.name),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Container(
                              height:
                                  sequence.sequence[index].duration / 500 + 0.0,
                              color: Colors.red.withOpacity(
                                  0.25 + Random().nextDouble() * 0.75),
                              child: FittedBox(
                                child: Text(sequence.sequence[index].name),
                              ),
                            );
                          },
                          itemCount: sequence.sequence.length,
                        )
                      ],
                    );
                  }),
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
