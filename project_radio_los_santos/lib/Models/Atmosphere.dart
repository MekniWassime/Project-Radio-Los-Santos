import 'dart:math';

import 'package:project_radio_los_santos/Models/AudioFile.dart';
import 'package:project_radio_los_santos/Services/MyUtility.dart';
import 'package:project_radio_los_santos/Services/AudioFileListExtention.dart';

class Atmosphere {
  final List<AudioFile> morning;
  final List<AudioFile> evening;
  final List<AudioFile> night;
  final List<AudioFile> sunny;
  final List<AudioFile> rain;
  final List<AudioFile> fog;
  final List<AudioFile> smog;
  final List<AudioFile> storm;
  final int maxDuration;

  Atmosphere({
    required this.morning,
    required this.evening,
    required this.night,
    required this.sunny,
    required this.rain,
    required this.fog,
    required this.smog,
    required this.storm,
  }) : maxDuration = MyUtility.getMax([
              morning.longestDuration(),
              evening.longestDuration(),
              night.longestDuration(),
              sunny.longestDuration(),
              rain.longestDuration(),
              fog.longestDuration(),
              smog.longestDuration(),
              storm.longestDuration()
            ]) ??
            0;
  //TODO; use smog and storm also treat the case where one of the lists or more are empty
  List<AudioFile> selectAppropriateAtmosphere(
      DateTime currentDate, bool isWeather) {
    int timeOfDay; //0: morning 1: evening 2:night
    int hour = currentDate.hour;
    if (hour >= 5 && hour <= 18)
      timeOfDay = 0;
    else if (hour >= 19 && hour <= 21)
      timeOfDay = 1;
    else
      timeOfDay = 2;
    if (isWeather || TimeOfDay(timeOfDay).isEmpty) {
      Random randGen = Random(currentDate.day);
      int month = currentDate.month;
      double randomDouble = randGen.nextDouble();
      if (randomDouble < 0.05 && smog.isNotEmpty) return smog;
      if (month >= 3 && month <= 5) {
        //spring
        if (randomDouble < 0.1 && rain.isNotEmpty)
          return rain;
        else if (timeOfDay == 0 && sunny.isNotEmpty) return sunny;
      } else if (month >= 6 && month <= 8) {
        //summer
        if (timeOfDay == 0 && sunny.isNotEmpty) return sunny;
      } else if (month >= 9 && month <= 11) {
        //fall
        if (randomDouble < 0.4 && rain.isNotEmpty)
          return rain;
        else {
          if (timeOfDay == 0 && sunny.isNotEmpty)
            return sunny;
          else if (randomDouble < 0.1 && fog.isNotEmpty) return fog;
        }
      } else {
        //winter
        if (randomDouble < 0.9 && rain.isNotEmpty)
          return rain;
        else if (randomDouble < 0.5 && storm.isNotEmpty)
          return storm;
        else {
          if (timeOfDay == 0 && sunny.isNotEmpty)
            return sunny;
          else if (randomDouble < 0.7 && fog.isNotEmpty) return fog;
        }
      }
    }
    return TimeOfDay(timeOfDay);
  }

  // ignore: non_constant_identifier_names
  List<AudioFile> TimeOfDay(int timeOfDay) {
    if (timeOfDay == 0)
      return morning;
    else if (timeOfDay == 1)
      return evening;
    else //if(timeOfDay == 2)
      return night;
  }

  factory Atmosphere.fromJson(json) {
    var morning =
        (json['morning'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var evening =
        (json['evening'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var night =
        (json['night'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var sunny =
        (json['sunny'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var rain =
        (json['rain'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var fog = (json['fog'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var smog =
        (json['smog'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var storm =
        (json['storm'] as List).map((e) => AudioFile.fromJson(e)).toList();
    return Atmosphere(
        morning: morning,
        evening: evening,
        night: night,
        sunny: sunny,
        rain: rain,
        fog: fog,
        smog: smog,
        storm: storm);
  }
}
