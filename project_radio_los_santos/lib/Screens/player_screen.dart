import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer player;
  bool loading = true;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    player = AudioPlayer();
    await player
        .setAsset("assets/audio/Adverts/Zebra Bar 1 (What about nuts).ogg");
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top, left: 10, right: 10),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                if (!loading) {
                  player.play();
                }
              },
              child: const Text(
                  "assets/audio/Adverts/'Law' on Weazel 2 ('Because paperwork is dramatic').ogg"),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
