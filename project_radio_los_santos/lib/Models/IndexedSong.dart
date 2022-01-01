import 'dart:math';

import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/IAudioFile.dart';
import 'package:project_radio_los_santos/Models/SequenceIndex.dart';
import 'package:project_radio_los_santos/Models/Song.dart';

class IndexedSong implements IAudioFile {
  final Song song;
  final int introIndex;
  final int midIndex;
  final int outroIndex;

  IndexedSong(
      {required this.song,
      required this.introIndex,
      required this.midIndex,
      required this.outroIndex});

  factory IndexedSong.random({required Song song, required Random randomGen}) {
    int introIdex = 0;
    int midIndex = 0;
    int outroIndex = 0;
    if (randomGen.nextDouble() < 0.6)
      introIdex = randomGen.nextInt(song.intro.length);
    if (randomGen.nextDouble() < 0.6)
      midIndex = randomGen.nextInt(song.mid.length);
    if (randomGen.nextDouble() < 0.6)
      outroIndex = randomGen.nextInt(song.outro.length);
    return IndexedSong(
        song: song,
        introIndex: introIdex,
        midIndex: midIndex,
        outroIndex: outroIndex);
  }

  @override
  List<AudioSource> get audioSources => [
        AudioSource.uri(Uri.parse("asset:///${song.intro[introIndex].path}")),
        AudioSource.uri(Uri.parse("asset:///${song.mid[midIndex].path}")),
        AudioSource.uri(Uri.parse("asset:///${song.outro[outroIndex].path}")),
      ];

  @override
  int get duration => song.duration;

  @override
  String get name => song.name;

  @override
  int get numberOfFiles => 3;

  @override
  SequenceIndex getFileOffset({
    required int currentIndex,
    required int currentPosition,
  }) {
    int indexOffset = 0;
    if (song.intro[introIndex].duration < currentPosition) {
      indexOffset++;
      currentPosition -= song.intro[introIndex].duration;
      if (song.mid[midIndex].duration < currentPosition) {
        indexOffset++;
        currentPosition -= song.mid[midIndex].duration;
      }
    }
    return SequenceIndex(
      index: currentIndex + indexOffset,
      position: Duration(
        milliseconds: currentPosition,
      ),
    );
  }

  @override
  String toString() {
    return song.name;
  }
}
