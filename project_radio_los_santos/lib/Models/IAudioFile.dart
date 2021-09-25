import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/SequenceIndex.dart';

abstract class IAudioFile {
  String get name;
  int get duration;
  List<AudioSource> get audioSources;
  int get numberOfFiles;
  SequenceIndex getFileOffset(
      {required int currentIndex, required int currentPosition});
}
