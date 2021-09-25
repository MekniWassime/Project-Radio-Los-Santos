import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:project_radio_los_santos/Models/AudioFile.dart';
import 'package:project_radio_los_santos/Models/RadioStation.dart';

class AudioData {
  static late final List<AudioFile>
      adverts; //adverts are sorted in ascending order
  static late final List<RadioStation> radioStations;
  static late final List<AudioFile> shortAdverts;
  static late final List<AudioFile> longAdverts;
  static late final AudioFile silent;

  static Future<void> initialize() async {
    String data = await rootBundle.loadString("assets/audio/metadata.json");
    final jsonData = jsonDecode(data);
    adverts = (jsonData['adverts'] as List)
        .map((e) => AudioFile.fromJson(e))
        .toList();
    radioStations = (jsonData['stations'] as List)
        .map((e) => RadioStation.fromJson(e))
        .toList();
    silent = AudioFile.fromJson(jsonData['silent']);
    int medianOfAdverts = adverts.length ~/ 2;
    shortAdverts = adverts.sublist(0, medianOfAdverts);
    longAdverts = adverts.sublist(medianOfAdverts);
    debugPrint("*\n**\n***\nLoaded Radio Stations :");
    for (var item in radioStations) {
      debugPrint(item.toString());
    }
  }
}
