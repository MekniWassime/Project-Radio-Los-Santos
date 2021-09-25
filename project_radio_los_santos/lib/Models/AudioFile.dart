import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/IAudioFile.dart';
import 'package:project_radio_los_santos/Models/SequenceIndex.dart';
import 'package:project_radio_los_santos/Services/PathService.dart';

class AudioFile implements IAudioFile {
  final String path;
  @override
  final int duration;

  AudioFile({required this.path, required this.duration});

  factory AudioFile.fromJson(json) {
    return AudioFile(
        path: PathService.appendAssetFolder(json['file']),
        duration: json['duration']);
  }

  @override
  String toString() {
    return "[$path, $duration]";
  }

  @override
  List<AudioSource> get audioSources =>
      [AudioSource.uri(Uri.parse("asset:///$path"))];

  @override
  String get name => path;

  @override
  int get numberOfFiles => 1;

  @override
  SequenceIndex getFileOffset(
      {required int currentIndex, required int currentPosition}) {
    return SequenceIndex(
        index: currentIndex, position: Duration(milliseconds: currentPosition));
  }
}
