import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/AudioFile.dart';
import 'package:project_radio_los_santos/Models/IAudioFile.dart';
import 'package:project_radio_los_santos/Models/IndexedSong.dart';

class Song {
  final String name;
  final List<AudioFile> intro;
  final List<AudioFile> mid;
  final List<AudioFile> outro;
  final int duration;

  Song(
      {required this.name,
      required this.intro,
      required this.mid,
      required this.outro})
      : duration = intro[0].duration + mid[0].duration + outro[0].duration;

  factory Song.fromJson(json) {
    var intro =
        (json['intro'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var mid = (json['mid'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var outro =
        (json['outro'] as List).map((e) => AudioFile.fromJson(e)).toList();
    return Song(name: json['name'], intro: intro, mid: mid, outro: outro);
  }

  IndexedSong getIndexedSong(
      {required int introIndex,
      required int midIndex,
      required int outroIndex}) {
    return IndexedSong(
        song: this,
        introIndex: introIndex,
        midIndex: midIndex,
        outroIndex: outroIndex);
  }
}
