import 'dart:math';

import 'package:project_radio_los_santos/Models/IPlayable.dart';
import 'package:project_radio_los_santos/Models/PlayableAudioFile.dart';
import 'package:project_radio_los_santos/Models/PlayableSong.dart';
import 'package:project_radio_los_santos/Models/RadioStation.dart';
import 'package:project_radio_los_santos/Services/AudioData.dart';

class Sequence {
  List<IPlayable> playabelSequence = [];
  late int startTime;
  late int seed;

  Sequence(RadioStation radioStation) {
    var currentDate = DateTime.now();
    int currentTimeInMilliseconds = currentDate.millisecondsSinceEpoch;
    int stationMaxDuration = radioStation.maxDuration;

    seed = currentTimeInMilliseconds ~/ stationMaxDuration;
    startTime = seed * stationMaxDuration;
    var randomGenerator = Random(seed);

    List<PlayableSong> playableSongs = radioStation.songs
        .map((e) => PlayableSong(
            song: e,
            introIndex: randomGenerator.nextInt(e.intro.length),
            midIndex: randomGenerator.nextInt(e.mid.length),
            outroIndex: randomGenerator.nextInt(e.outro.length)))
        .toList();

    List<PlayableAudioFile> playableShortAdverts =
        AudioData.shortAdverts.map((e) => PlayableAudioFile(file: e)).toList();

    List<PlayableAudioFile> playableLongAdverts =
        AudioData.longAdverts.map((e) => PlayableAudioFile(file: e)).toList();

    List<PlayableAudioFile> playableID =
        radioStation.id.map((e) => PlayableAudioFile(file: e)).toList();

    List<PlayableAudioFile> playableDJAndCaller = radioStation.djAndCaller
        .map((e) => PlayableAudioFile(file: e))
        .toList();

    List<PlayableAudioFile> playableAtmosphere = radioStation.atmosphere
        .selectAppropriateAtmosphere(currentDate, randomGenerator.nextBool())
        .map((e) => PlayableAudioFile(file: e))
        .toList();

    int songsRemaining = playableSongs.length;
    while (songsRemaining != 0) {
      //add a song
      int songIndex = randomGenerator.nextInt(songsRemaining);
      playabelSequence.add(playableSongs[songIndex]);
      playableSongs.removeAt(songIndex);
      songsRemaining--;
      //add an id
      playabelSequence
          .add(playableID[randomGenerator.nextInt(playableID.length)]);
      //weather and time of day updates
      double randomDouble = randomGenerator.nextDouble();
      if (randomDouble < 0.2 * (1 / radioStation.songs.length)) {
        int atmoIndex = randomGenerator.nextInt(songsRemaining);
        playabelSequence.add(playableAtmosphere[atmoIndex]);
        playableAtmosphere.removeAt(atmoIndex);
      }
      //add a caller or dj commentary or nothing
      randomDouble = randomGenerator.nextDouble();
      if (randomDouble > 0.75 && playableDJAndCaller.length > 0) {
        int djAndCallerIndex =
            randomGenerator.nextInt(playableDJAndCaller.length);
        playabelSequence.add(playableDJAndCaller[djAndCallerIndex]);
        playableDJAndCaller.removeAt(djAndCallerIndex);
      }
      randomDouble = randomGenerator.nextDouble();
      //add a short ad and long ad in a random order
      if (randomDouble < 0.5) {
        playabelSequence.add(playableShortAdverts[
            randomGenerator.nextInt(playableShortAdverts.length)]);
        playabelSequence.add(playableLongAdverts[
            randomGenerator.nextInt(playableLongAdverts.length)]);
      } else {
        playabelSequence.add(playableLongAdverts[
            randomGenerator.nextInt(playableLongAdverts.length)]);
        playabelSequence.add(playableShortAdverts[
            randomGenerator.nextInt(playableShortAdverts.length)]);
      }
    }
    print(
        "max length: ${radioStation.maxDuration}, seq length: ${duration}, difference: ${radioStation.maxDuration - duration}");
  }

  int get duration {
    int seqDuration = 0;
    for (var item in playabelSequence) seqDuration += item.duration;
    return seqDuration;
  }

  String toString() {
    String result = "Sequence: ";
    for (var playable in playabelSequence) {
      result += playable.toString();
    }
    return result;
  }
}
