import 'package:audio_service/audio_service.dart';

class MyAudioHandler extends BaseAudioHandler {
  static late AudioHandler _audioHandler;

  AudioHandler get instance => _audioHandler;

  static Future<void> initService() async {
    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.mycompany.myapp.audio',
        androidNotificationChannelName: 'Audio Service Demo',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }
}
