import 'package:project_radio_los_santos/Services/PathService.dart';

class AudioFile {
  final String path;
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
}
