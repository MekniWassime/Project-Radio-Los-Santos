import 'package:project_radio_los_santos/Models/AudioFile.dart';
import 'package:project_radio_los_santos/Models/IPlayable.dart';

class PlayableAudioFile implements IPlayable {
  final AudioFile file;

  PlayableAudioFile({required this.file});

  @override
  int get duration => file.duration;

  @override
  String toString() {
    return "\n   [${file.path.substring(19)}:${file.duration}]";
  }
}
