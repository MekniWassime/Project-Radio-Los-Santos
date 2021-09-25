import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/IAudioFile.dart';
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

  @override
  List<AudioSource> get audioSources => [
        AudioSource.uri(Uri.parse("asset:///${song.intro[introIndex].path}")),
        AudioSource.uri(Uri.parse("asset:///${song.mid[midIndex].path}")),
        AudioSource.uri(Uri.parse("asset:///${song.outro[outroIndex].path}")),
      ];

  @override
  int get duration => song.duration;
}
