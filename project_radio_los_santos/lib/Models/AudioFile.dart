import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/IAudioFile.dart';
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
}
