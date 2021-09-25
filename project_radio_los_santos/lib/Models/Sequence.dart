// ignore_for_file: prefer_adjacent_string_concatenation

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/AudioFile.dart';

import 'package:project_radio_los_santos/Models/IAudioFile.dart';
import 'package:project_radio_los_santos/Models/IndexedSong.dart';
import 'package:project_radio_los_santos/Models/LimitedFileList.dart';
import 'package:project_radio_los_santos/Models/RadioStation.dart';
import 'package:project_radio_los_santos/Models/SequenceIndex.dart';
import 'package:project_radio_los_santos/Models/SilentAudioFile.dart';
import 'package:project_radio_los_santos/Models/Song.dart';
import 'package:project_radio_los_santos/Services/AudioData.dart';
import 'package:project_radio_los_santos/Services/AudioFileListExtention.dart';

class Sequence {
  List<IAudioFile> sequence = [];
  late int startTime;
  late int seed;
  late int duration;
  late int endTime;
  late int maxEndTime;
  late RadioStation radioStation;

  Sequence._build(this.radioStation, {int? setSeed, int seedOffset = 0}) {
    debugPrint("****\ngenerating sequence\n****");
    var currentDate = DateTime.now();
    int currentTimeInMilliseconds = currentDate.millisecondsSinceEpoch;
    int stationMaxDuration = radioStation.maxDuration;
    seed =
        setSeed ?? currentTimeInMilliseconds ~/ stationMaxDuration + seedOffset;
    startTime = seed * stationMaxDuration;
    debugPrint(
      "    seed = $seed" +
          "\n    current time = ${DateTime.now()}" +
          "\n    start time = ${DateTime.fromMillisecondsSinceEpoch(startTime)}",
    );
    var randomGenerator = Random(seed);
    var songsList = LimitedFileList(
      list: radioStation.songs
          .map((song) =>
              IndexedSong.random(song: song, randomGen: randomGenerator))
          .toList(),
      randomGenerator: randomGenerator,
    );
    int numberOfSongs = songsList.listLength;
    int thirdOfSongs = numberOfSongs ~/ 3;
    var longAdvertsList = LimitedFileList(
        debug: true,
        list: AudioData.longAdverts,
        emptyProbablity: 1 / 3,
        randomGenerator: randomGenerator,
        effectiveLength: numberOfSongs - thirdOfSongs);
    var shortAdvertsList = LimitedFileList(
        list: AudioData.shortAdverts,
        emptyProbablity: 1 / 3,
        randomGenerator: randomGenerator,
        effectiveLength: numberOfSongs - thirdOfSongs);
    var idList = LimitedFileList(
        list: radioStation.id, infinit: true, randomGenerator: randomGenerator);
    var djList = LimitedFileList(
        list: radioStation.dj,
        randomGenerator: randomGenerator,
        emptyProbablity:
            1 - max<double>(1, radioStation.dj.length / numberOfSongs));
    var atmosphereList = LimitedFileList(
        list: radioStation.atmosphere.selectAppropriateAtmosphere(
            DateTime.fromMillisecondsSinceEpoch(startTime),
            randomGenerator.nextBool()),
        randomGenerator: randomGenerator,
        effectiveLength: 1,
        emptyProbablity: 1 - 0.4 * (1 / numberOfSongs));
    List<AudioFile>.from(radioStation.atmosphere.selectAppropriateAtmosphere(
        DateTime.fromMillisecondsSinceEpoch(startTime),
        randomGenerator.nextBool()));
    var specialList = LimitedFileList(
        list: radioStation.special,
        randomGenerator: randomGenerator,
        effectiveLength: 1,
        emptyProbablity: 1 - 0.4 * (1 / numberOfSongs));
    //silent audioFile used to add short seperation between audio files
    SilentAudioFile silentFile = SilentAudioFile();
    silentFile.setDuration(radioStation.silenceDuration);
    while (!songsList.isEmpty) {
      //add song audio files
      if (sequence.addNotNull(songsList.getAudioFile()))
        sequence.add(silentFile);
      //add an id
      if (sequence.addNotNull(idList.getAudioFile())) sequence.add(silentFile);
      //weather and time of day updates
      if (sequence.addNotNull(atmosphereList.getAudioFile()))
        sequence.add(silentFile);
      //add a caller or dj commentary or nothing
      if (sequence.addNotNull(djList.getAudioFile())) sequence.add(silentFile);
      //add a short ad and long ad in a random order
      if (randomGenerator.nextDouble() < 0.5) {
        if (sequence.addNotNull(shortAdvertsList.getAudioFile()))
          sequence.add(silentFile);
        if (sequence.addNotNull(longAdvertsList.getAudioFile()))
          sequence.add(silentFile);
      } else {
        if (sequence.addNotNull(longAdvertsList.getAudioFile()))
          sequence.add(silentFile);
        if (sequence.addNotNull(shortAdvertsList.getAudioFile()))
          sequence.add(silentFile);
      }
      //add special events commentary
      if (sequence.addNotNull(specialList.getAudioFile()))
        sequence.add(silentFile);
    }
    //need to fill the difference between the sequence current length and the max length of the radio station
    duration = sequence.totalDuration;
    int difference = radioStation.maxDuration - duration;
    shortAdvertsList.reset(
      emptyProbablity: 0,
      infinit: true,
      effectiveLength: 10,
    );
    longAdvertsList.reset(
      emptyProbablity: 0,
      infinit: true,
      effectiveLength: 10,
    );
    songsList.reset(
      infinit: true,
      effectiveLength: 10,
      emptyProbablity: 0,
    );
    int shortestDuration = min<int>(
      shortAdvertsList.shortestDuration(),
      idList.shortestDuration(),
    );
    while (difference >= shortestDuration) {
      //add song audio files
      if (sequence.addNotNull(songsList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
      }
      //add an id
      if (sequence.addNotNull(idList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
      }
      //weather and time of day updates
      if (sequence.addNotNull(atmosphereList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
      }
      //add a caller or dj commentary or nothing
      if (sequence.addNotNull(djList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
      }
      //add a short ad and long ad in a random order
      if (sequence.addNotNull(longAdvertsList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
      }
      if (sequence.addNotNull(shortAdvertsList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
      }
      //add special events commentary
      if (sequence.addNotNull(specialList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
      }
    }
    //remove the last silent file
    int numberOfSilentFiles = (sequence.length ~/ 2) - 1;
    sequence.removeLast();
    //calculate duration and difference
    duration = sequence.totalDuration;
    difference = radioStation.maxDuration - duration;
    //expand silence period to fill the remaining difference
    silentFile.setDuration(radioStation.silenceDuration +
        max(radioStation.silenceDuration, difference ~/ numberOfSilentFiles));
    //calculate duration and difference
    duration = sequence.totalDuration;
    difference = radioStation.maxDuration - duration;
    //final radio stats
    endTime = startTime + duration;
    maxEndTime = startTime + radioStation.maxDuration;
    debugPrint(
      "    max end time = ${DateTime.fromMillisecondsSinceEpoch(startTime + radioStation.maxDuration)}" +
          "\n    end time = ${DateTime.fromMillisecondsSinceEpoch(endTime)}" +
          "\n    max length: ${radioStation.maxDuration}, seq length: $duration, difference: ${radioStation.maxDuration - duration}" +
          "\nfirst file = ${sequence[0]}",
    );
  }

  int get pointerPosition => DateTime.now().millisecondsSinceEpoch - startTime;

  int get millisecondsUntilMaxEnd =>
      maxEndTime - DateTime.now().millisecondsSinceEpoch;

  bool isOver() {
    return pointerPosition > duration;
  }

  bool isNotReached() {
    return pointerPosition < 0;
  }

  bool isInInterval() {
    var pointer = pointerPosition;
    return pointer >= 0 && pointer <= duration;
  }

  bool isCurrent() {
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    return currentTime >= startTime && currentTime <= maxEndTime;
  }

  SequenceIndex getCurrentIndex() {
    int pointer = pointerPosition;
    if (pointer < 0)
      throw SequenceNotReachedYetException();
    else if (pointer > duration) throw SequenceOverException();
    int tempPointer = 0;
    int sequenceIndex = 0;
    int fileIndex = 0;
    var audioFile = sequence[sequenceIndex];
    while (tempPointer + audioFile.duration < pointer) {
      tempPointer += audioFile.duration;
      sequenceIndex++;
      fileIndex += audioFile.numberOfFiles;
      audioFile = sequence[sequenceIndex];
    }
    return audioFile.getFileOffset(
        currentIndex: fileIndex, currentPosition: pointer - tempPointer);
  }

  ConcatenatingAudioSource getPlaylist() {
    List<AudioSource> result = [];
    for (var file in sequence) result.addAll(file.audioSources);
    return ConcatenatingAudioSource(children: result);
  }

  factory Sequence.buildCurrent({required RadioStation radioStation}) {
    return Sequence._build(radioStation);
  }

  factory Sequence.buildNext({required RadioStation radioStation}) {
    return Sequence._build(radioStation, seedOffset: 1);
  }

  factory Sequence.buildFromSeed(
      {required RadioStation radioStation, required int seed}) {
    return Sequence._build(radioStation, setSeed: seed);
  }

  @override
  String toString() {
    String result = "Sequence: ";
    for (var item in sequence) {
      result += item.toString();
    }
    return result;
  }

  Sequence getNextSequence() {
    return Sequence.buildFromSeed(radioStation: radioStation, seed: seed + 1);
  }
}

class SequenceOverException implements Exception {}

class SequenceNotReachedYetException implements Exception {}
