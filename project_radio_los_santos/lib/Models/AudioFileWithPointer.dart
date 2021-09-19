import 'package:project_radio_los_santos/Models/AudioFile.dart';

class AudioFileWithPointer extends AudioFile {
  final int pointer;
  AudioFileWithPointer(AudioFile file, {required this.pointer})
      : assert(pointer >= 0 && pointer < file.duration, "pointer out of range"),
        super(duration: file.duration, path: file.path);
}
