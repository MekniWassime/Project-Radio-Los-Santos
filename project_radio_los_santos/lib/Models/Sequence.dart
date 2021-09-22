// ignore_for_file: prefer_adjacent_string_concatenation

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:project_radio_los_santos/Models/AudioFile.dart';
import 'package:project_radio_los_santos/Models/AudioFileWithPointer.dart';
import 'package:project_radio_los_santos/Models/RadioStation.dart';
import 'package:project_radio_los_santos/Models/SequenceIndex.dart';
import 'package:project_radio_los_santos/Models/Song.dart';
import 'package:project_radio_los_santos/Services/AudioData.dart';
import 'package:project_radio_los_santos/Services/AudioFileListExtention.dart';

class Sequence {
  List<AudioFile> sequence = [];
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
    //seed = currentTimeInMilliseconds ~/ stationMaxDuration + seedOffset;
    startTime = seed * stationMaxDuration;
    debugPrint(
      "    seed = $seed" +
          "\n    current time = ${DateTime.now()}" +
          "\n    start time = ${DateTime.fromMillisecondsSinceEpoch(startTime)}",
    );
    var randomGenerator = Random(seed);
    var songs = List<Song>.from(radioStation.songs);
    var longAdverts = List<AudioFile>.from(AudioData.longAdverts);
    var shortAdverts = List<AudioFile>.from(AudioData.shortAdverts);
    var id = List<AudioFile>.from(radioStation.id);
    var djAndCaller = List<AudioFile>.from(radioStation.djAndCaller);
    var atmosphere = List<AudioFile>.from(radioStation.atmosphere
        .selectAppropriateAtmosphere(
            DateTime.fromMillisecondsSinceEpoch(startTime),
            randomGenerator.nextBool()));
    int songsRemaining = songs.length;

    while (songsRemaining != 0) {
      //add song audio files
      int songIndex = randomGenerator.nextInt(songsRemaining);
      var song = songs[songIndex];
      sequence.addAll(song.getAudioFiles(
          introIndex: randomGenerator.nextInt(song.intro.length),
          midIndex: randomGenerator.nextInt(song.mid.length),
          outroIndex: randomGenerator.nextInt(song.outro.length)));
      songs.removeAt(songIndex);
      songsRemaining--;
      //add an id
      sequence.add(id[randomGenerator.nextInt(id.length)]);
      //weather and time of day updates
      double randomDouble = randomGenerator.nextDouble();
      if (randomDouble < 0.2 * (1 / radioStation.songs.length)) {
        int atmoIndex = randomGenerator.nextInt(atmosphere.length);
        sequence.add(atmosphere[atmoIndex]);
        atmosphere.removeAt(atmoIndex);
      }
      //add a caller or dj commentary or nothing
      randomDouble = randomGenerator.nextDouble();
      if (randomDouble > 0.75 && djAndCaller.isNotEmpty) {
        int djAndCallerIndex = randomGenerator.nextInt(djAndCaller.length);
        sequence.add(djAndCaller[djAndCallerIndex]);
        djAndCaller.removeAt(djAndCallerIndex);
      }
      randomDouble = randomGenerator.nextDouble();
      //add a short ad and long ad in a random order
      if (randomDouble < 0.5) {
        sequence
            .add(shortAdverts[randomGenerator.nextInt(shortAdverts.length)]);
        sequence.add(longAdverts[randomGenerator.nextInt(longAdverts.length)]);
      } else {
        sequence.add(longAdverts[randomGenerator.nextInt(longAdverts.length)]);
        sequence
            .add(shortAdverts[randomGenerator.nextInt(shortAdverts.length)]);
      }
    }
    //need to fill the difference between the sequence current length and the max length of the radio station
    duration = sequence.sumDuration();
    int difference = radioStation.maxDuration - duration;
    int shortestFile = min<int>(
        shortAdverts.shortestFile().duration, id.shortestFile().duration);
    songs = List<Song>.from(radioStation.songs);
    while (difference >= shortestFile) {
      var viableSongs =
          songs.where((element) => element.duration <= difference).toList();
      if (viableSongs.isNotEmpty) {
        int songIndex = randomGenerator.nextInt(viableSongs.length);
        var song = viableSongs[songIndex];
        sequence.addAll(song.getAudioFiles(
            introIndex: randomGenerator.nextInt(song.intro.length),
            midIndex: randomGenerator.nextInt(song.mid.length),
            outroIndex: randomGenerator.nextInt(song.outro.length)));
        songs.remove(song);
        difference -= song.duration;
      }
      id = radioStation.id
          .where((element) => element.duration <= difference)
          .toList();
      if (id.isNotEmpty) {
        int idIndex = randomGenerator.nextInt(id.length);
        sequence.add(id[idIndex]);
        difference -= id[idIndex].duration;
      }
      longAdverts = AudioData.longAdverts
          .where((element) => element.duration <= difference)
          .toList();
      if (longAdverts.isNotEmpty) {
        int adIndex = randomGenerator.nextInt(longAdverts.length);
        sequence.add(longAdverts[adIndex]);
        difference -= longAdverts[adIndex].duration;
      }
      shortAdverts = AudioData.shortAdverts
          .where((element) => element.duration <= difference)
          .toList();
      if (shortAdverts.isNotEmpty) {
        int adIndex = randomGenerator.nextInt(shortAdverts.length);
        sequence.add(shortAdverts[adIndex]);
        difference -= shortAdverts[adIndex].duration;
      }
    }
    duration = sequence.sumDuration();
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
    int fileIndex = 0;
    var audioFile = sequence[fileIndex];
    while (tempPointer + audioFile.duration < pointer) {
      tempPointer += audioFile.duration;
      fileIndex++;
      audioFile = sequence[fileIndex];
    }
    return SequenceIndex(
        index: fileIndex,
        position: Duration(milliseconds: pointer - tempPointer));
  }

  ConcatenatingAudioSource getPlaylist() {
    return ConcatenatingAudioSource(
        children: sequence
            .map((e) => AudioSource.uri(Uri.parse("asset:///${e.path}")))
            .toList());
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
