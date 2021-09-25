import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/IAudioFile.dart';

class EmptyAudioFile implements IAudioFile {
  @override
  List<AudioSource> get audioSources => [];

  @override
  int get duration => 0;
}
