import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:project_radio_los_santos/Models/Atmosphere.dart';
import 'package:project_radio_los_santos/Models/AudioFile.dart';
import 'package:project_radio_los_santos/Models/Song.dart';
import 'package:project_radio_los_santos/Services/AudioData.dart';
import 'package:project_radio_los_santos/Services/AudioFileListExtention.dart';
import 'package:project_radio_los_santos/Services/PathService.dart';

class RadioStation {
  final String name;
  final Atmosphere atmosphere;
  final List<AudioFile> special;
  final List<AudioFile> dj;
  final List<AudioFile> id;
  final List<Song> songs;
  int? _maxDurationCache;
  int silenceDuration = 250;
  final double idRatio;
  final double djRatio;
  final double atmoRatio;
  final double specialRatio;
  final double shortAdRatio;
  final double longAdRatio;

  RadioStation({
    required this.name,
    required this.atmosphere,
    required this.dj,
    required this.id,
    required this.songs,
    required this.special,
    this.idRatio = 0.4,
    this.djRatio = 0.3,
    this.atmoRatio = 0.1,
    this.specialRatio = 0.1,
    this.shortAdRatio = 0.15,
    this.longAdRatio = 0.08,
  });

  int get maxDuration {
    int? currentCache = _maxDurationCache;
    if (currentCache == null) {
      currentCache = _calculateMaxDuration();
      _maxDurationCache = currentCache;
      return currentCache;
    } else {
      return currentCache;
    }
  }

  int _calculateMaxDuration() {
    int maxDuration = _sumDurationOfSongs();
    int numberOfSongs = songs.length; //length is supposed to be >2

    numberOfSongs = songs.length;

    maxDuration += (id.longestDuration() * numberOfSongs * idRatio).round();

    maxDuration +=
        (AudioData.longAdverts.longestDuration() * numberOfSongs * longAdRatio)
            .round();
    maxDuration += (AudioData.shortAdverts.longestDuration() *
            numberOfSongs *
            shortAdRatio)
        .toInt();
    //one atmoshpere info are played
    maxDuration += atmosphere.maxDuration;
    //one special is played
    maxDuration += special.longestDuration();
    //play max possible number of dj and caller without repeating
    int minUnique = min<int>(dj.length, numberOfSongs);
    maxDuration += dj.maxDurationForNumberOfElements(minUnique);
    //silence of 500 ms added after each file (except the end)
    maxDuration += (numberOfSongs +
            (numberOfSongs * shortAdRatio).round() +
            (numberOfSongs * longAdRatio).round() +
            minUnique +
            1) *
        silenceDuration;
    return maxDuration;
  }

  int _sumDurationOfSongs() {
    int duration = 0;
    for (var song in songs) duration += song.duration;
    return duration;
  }

  factory RadioStation.fromJson(json) {
    var atmosphere = Atmosphere.fromJson(json['atmosphere']);
    var special =
        (json['special'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var id = (json['id'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var dj = (json['dj'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var songs = (json['songs'] as List).map((e) => Song.fromJson(e)).toList();
    return RadioStation(
        special: special,
        name: json['name'],
        atmosphere: atmosphere,
        dj: dj,
        id: id,
        songs: songs,
        idRatio: json['idRatio'] ?? 0.4,
        atmoRatio: json['atmoRatio'] ?? 0.1,
        djRatio: json['djRatio'] ?? 0.3,
        longAdRatio: json['longAdRatio'] ?? 0.08,
        shortAdRatio: json['shortAdRatio'] ?? 0.15,
        specialRatio: json['specialRatio'] ?? 0.08);
  }

  MediaItem getMediaItem() {
    return MediaItem(id: name, title: name);
  }

  @override
  String toString() {
    return "RadioStation $name, songs(${songs.length}), dj(${dj.length}), id(${id.length})), special(${special.length})";
  }
}
