import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/RadioStation.dart';
import 'package:project_radio_los_santos/Models/Sequence.dart';
import 'package:project_radio_los_santos/Services/AudioData.dart';

class MyAudioHandler extends BaseAudioHandler {
  static late MyAudioHandler _audioHandler;
  final _player = AudioPlayer();
  final List<RadioStation> radioStations = AudioData.radioStations;
  int currentRadioIndex;
  RadioStation get currentStation => radioStations[currentRadioIndex];
  late Sequence currentSequence =
      Sequence.buildCurrent(radioStation: currentStation);
  late Sequence nextSequence = currentSequence.getNextSequence();
  final StreamController<Sequence> _sequenceStream =
      StreamController<Sequence>();

  static MyAudioHandler get instance => _audioHandler;
  Stream<Sequence> get sequenceStream => _sequenceStream.stream;
  static Future<void> initService() async {
    await AudioService.init(
      builder: () {
        _audioHandler = MyAudioHandler();
        return _audioHandler;
      },
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mycompany.myapp.audio',
        androidNotificationChannelName: 'Audio Service Demo',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }

  MyAudioHandler() : currentRadioIndex = 0 {
    currentRadioIndex = Random().nextInt(radioStations.length);
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.playerStateStream.listen((state) {
      if (state.playing && state.processingState == ProcessingState.completed) {
        debugPrint("\n\n*\nPlalist finished\n*\n");
        play();
      }
    });
    mediaItem.add(currentStation.getMediaItem());
    //mediaItem.add(const MediaItem(id: "fgsdgsg", title: "Test title"));
    //_player.setAudioSource(AudioSource.uri(Uri.parse(currentStation.)));
  }

  Future<void> validateSequence() async {
    if (currentSequence.isCurrent()) {
      if (currentSequence.isOver()) {
        await Future.delayed(Duration(
            milliseconds: currentSequence.millisecondsUntilMaxEnd + 1));
        validateSequence();
      }
    } else {
      if (nextSequence.isCurrent()) {
        currentSequence = nextSequence;
        nextSequence = currentSequence.getNextSequence();
      } else {
        currentSequence = Sequence.buildCurrent(radioStation: currentStation);
        nextSequence = currentSequence.getNextSequence();
      }
      _sequenceStream.add(currentSequence);
    }
  }

  @override
  Future<void> play() async {
    await validateSequence();
    pause();
    ConcatenatingAudioSource playlist = currentSequence.getPlaylist();
    var index = currentSequence.getCurrentIndex();
    await _player.setAudioSource(playlist,
        initialIndex: index.index, initialPosition: index.position);
    _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToPrevious() async {
    setRadioStationIndex(currentRadioIndex - 1);
  }

  void setRadioStationIndex(int newIndex) async {
    print("newIndex=$newIndex nbStations=${radioStations.length}");
    while (newIndex < 0) newIndex += radioStations.length;
    newIndex = newIndex % radioStations.length;
    print("finalIndex=$newIndex nbStations=${radioStations.length}");
    assert(newIndex >= 0 && newIndex < radioStations.length, "invalid range");
    currentRadioIndex = newIndex;
    currentSequence = Sequence.buildCurrent(radioStation: currentStation);
    nextSequence = currentSequence.getNextSequence();
    _sequenceStream.add(currentSequence);
    await pause();
    play();
    mediaItem.add(currentStation.getMediaItem());
  }

  @override
  Future<void> skipToNext() async {
    setRadioStationIndex(currentRadioIndex + 1);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
