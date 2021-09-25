import 'package:just_audio/just_audio.dart';

abstract class IAudioFile {
  int get duration;
  List<AudioSource> get audioSources;
}
