import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/AudioFile.dart';
import 'package:project_radio_los_santos/Models/IAudioFile.dart';
import 'package:project_radio_los_santos/Services/AudioData.dart';

class SilentAudioFile implements IAudioFile {
  List<AudioSource> audioSourcesCache = [];
  @override
  List<AudioSource> get audioSources => audioSourcesCache;

  @override
  int duration = 0;

  void setDuration(int durationInMillis) {
    duration = durationInMillis;
    audioSourcesCache = [];
    AudioFile silent = AudioData.silent;
    while (silent.duration < durationInMillis) {
      audioSourcesCache
          .add(AudioSource.uri(Uri.parse("asset:///${silent.path}")));
      durationInMillis -= silent.duration;
    }
    if (durationInMillis != 0)
      audioSourcesCache.add(
        ClippingAudioSource(
            child: AudioSource.uri(Uri.parse("asset:///${silent.path}")),
            end: Duration(milliseconds: durationInMillis)),
      );
  }
}
