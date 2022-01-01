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
    //debugPrint("1");
    /*debugPrint(
      "    seed = $seed" +
          "\n    current time = ${DateTime.now()}" +
          "\n    start time = ${DateTime.fromMillisecondsSinceEpoch(startTime)}",
    );*/
    var randomGenerator = Random(seed);
    //debugPrint("2");
    var songsList = LimitedFileList(
      list: radioStation.songs
          .map((song) =>
              IndexedSong.random(song: song, randomGen: randomGenerator))
          .toList(),
      randomGenerator: randomGenerator,
    );
    int numberOfSongs = songsList.listLength;
    var longAdvertsList = LimitedFileList(
      list: AudioData.longAdverts,
      emptyProbablity: 1 - radioStation.longAdRatio,
      randomGenerator: randomGenerator,
      effectiveLength: (numberOfSongs * radioStation.longAdRatio).round(),
    );
    var shortAdvertsList = LimitedFileList(
      list: AudioData.shortAdverts,
      emptyProbablity: 1 - radioStation.shortAdRatio,
      randomGenerator: randomGenerator,
      effectiveLength: (numberOfSongs * radioStation.shortAdRatio).round(),
    );
    var idList = LimitedFileList(
      list: radioStation.id,
      randomGenerator: randomGenerator,
      emptyProbablity: 1 - radioStation.idRatio,
      effectiveLength: (numberOfSongs * radioStation.idRatio).round(),
    );
    var djList = LimitedFileList(
      list: radioStation.dj,
      randomGenerator: randomGenerator,
      emptyProbablity: 1 - radioStation.djRatio,
      effectiveLength: (numberOfSongs * radioStation.djRatio).round(),
    );
    var atmosphereList = LimitedFileList(
      list: radioStation.atmosphere.selectAppropriateAtmosphere(
          DateTime.fromMillisecondsSinceEpoch(startTime),
          randomGenerator.nextBool()),
      randomGenerator: randomGenerator,
      effectiveLength: 1,
      emptyProbablity: 1 - radioStation.atmoRatio,
    );
    var specialList = LimitedFileList(
      list: radioStation.special,
      randomGenerator: randomGenerator,
      effectiveLength: 1,
      emptyProbablity: 1 - radioStation.specialRatio,
    );
    //silent audioFile used to add short seperation between audio files
    SilentAudioFile silentFile = SilentAudioFile();
    silentFile.setDuration(radioStation.silenceDuration);
    //debugPrint("3");
    while (!songsList.isEmpty) {
      bool addedId = false;
      bool isIdEmpty = idList.list.isEmpty;
      //debugPrint("4");
      //add song audio files
      if (sequence.addNotNull(songsList.getAudioFile()))
        sequence.add(silentFile);
      //add an id
      if (sequence.addNotNull(idList.getAudioFile())) {
        sequence.add(silentFile);
        addedId = true;
      }
      //weather and time of day updates
      if ((isIdEmpty || !addedId) &&
          sequence.addNotNull(atmosphereList.getAudioFile()))
        sequence.add(silentFile);
      //add a caller or dj commentary or nothing
      if ((isIdEmpty || addedId) && sequence.addNotNull(djList.getAudioFile()))
        sequence.add(silentFile);
      //add a short ad and long ad in a random order
      if (randomGenerator.nextDouble() < 0.5) {
        if ((isIdEmpty || addedId) &&
            sequence.addNotNull(shortAdvertsList.getAudioFile()))
          sequence.add(silentFile);
        if ((isIdEmpty || addedId) &&
            sequence.addNotNull(longAdvertsList.getAudioFile()))
          sequence.add(silentFile);
      } else {
        if ((isIdEmpty || addedId) &&
            sequence.addNotNull(longAdvertsList.getAudioFile()))
          sequence.add(silentFile);
        if ((isIdEmpty || addedId) &&
            sequence.addNotNull(shortAdvertsList.getAudioFile()))
          sequence.add(silentFile);
      }
      //add special events commentary
      if ((isIdEmpty || !addedId) &&
          sequence.addNotNull(specialList.getAudioFile()))
        sequence.add(silentFile);
    }
    //debugPrint("5");
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
    idList.reset(infinit: true, effectiveLength: 10, emptyProbablity: 0);
    int shortestDuration = min<int>(
      shortAdvertsList.shortestDuration(),
      idList.shortestDuration(),
    );
    int maxIter = 10;
    debugPrint("6");
    while (difference >= shortestDuration && maxIter > 0) {
      maxIter--;
      debugPrint("7");
      //add song audio files
      if (sequence.addNotNull(songsList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
        //print("added song");
      }
      //add an id
      idList.reset();
      if (sequence.addNotNull(idList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
        //print("added id");
      }
      //weather and time of day updates
      if (sequence.addNotNull(atmosphereList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
        //print("added atmoshpere");
      }
      //add a caller or dj commentary or nothing
      if (sequence.addNotNull(djList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
        //print("added dj");
      }
      //add a short ad and long ad in a random order
      longAdvertsList.reset();
      if (sequence.addNotNull(longAdvertsList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
        //print("added long ad");
      }
      shortAdvertsList.reset();
      if (sequence.addNotNull(shortAdvertsList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
        //print("added short ad");
      }
      //add special events commentary
      if (sequence.addNotNull(specialList.getAudioFile(
        filter: (file) => file.duration + silentFile.duration <= difference,
      ))) {
        difference -= sequence.last.duration + silentFile.duration;
        sequence.add(silentFile);
        //print("added special");
      }
    }
    //remove the last silent file
    int numberOfSilentFiles = (sequence.length ~/ 2) - 1;
    sequence.removeLast();
    //calculate duration and difference
    duration = sequence.totalDuration;
    difference = radioStation.maxDuration - duration;
    //expand silence period to fill the remaining difference
    //print("nb silent = $numberOfSilentFiles, difference = $difference, new padding = ${radioStation.silenceDuration + min<int>(difference ~/ numberOfSilentFiles, radioStation.silenceDuration ~/ 2)}");
    silentFile.setDuration(
      radioStation.silenceDuration +
          min<int>(
            difference ~/ numberOfSilentFiles,
            radioStation.silenceDuration ~/ 2,
          ),
    );
    //calculate duration and difference
    duration = sequence.totalDuration;
    difference = radioStation.maxDuration - duration;
    //final radio stats
    endTime = startTime + duration;
    maxEndTime = startTime + radioStation.maxDuration;
    //debugPrint("9");
    /*debugPrint(
      "    max end time = ${DateTime.fromMillisecondsSinceEpoch(startTime + radioStation.maxDuration)}" +
          "\n    end time = ${DateTime.fromMillisecondsSinceEpoch(endTime)}" +
          "\n    max length: ${radioStation.maxDuration}, seq length: $duration, difference: ${radioStation.maxDuration - duration}" +
          "\nfirst file = ${sequence[0]}",
    );*/
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
    String result = "Sequence: \n";
    for (var item in sequence) {
      result += item.toString() + "\n";
    }
    result +=
        "    max end time = ${DateTime.fromMillisecondsSinceEpoch(startTime + radioStation.maxDuration)}" +
            "\n    end time = ${DateTime.fromMillisecondsSinceEpoch(endTime)}" +
            "\n    max length: ${radioStation.maxDuration}, seq length: $duration, difference: ${radioStation.maxDuration - duration}";
    return result;
  }

  Sequence getNextSequence() {
    return Sequence.buildFromSeed(radioStation: radioStation, seed: seed + 1);
  }
}

class SequenceOverException implements Exception {}

class SequenceNotReachedYetException implements Exception {}
