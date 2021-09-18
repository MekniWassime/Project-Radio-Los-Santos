import 'package:project_radio_los_santos/Models/IPlayable.dart';
import 'package:project_radio_los_santos/Models/Song.dart';

class PlayableSong implements IPlayable {
  final Song song;
  final int introIndex;
  final int midIndex;
  final int outroIndex;

  PlayableSong(
      {required this.song,
      required this.introIndex,
      required this.midIndex,
      required this.outroIndex});

  @override
  int get duration => song.duration;

  @override
  String toString() {
    return "\n[song:${duration}]";
  }
}
