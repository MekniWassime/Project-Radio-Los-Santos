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
  final String art;
  final List<AudioFile> djAndCaller;
  final List<AudioFile> id;
  final List<Song> songs;
  int? _maxDurationCache;

  RadioStation(
      {required this.name,
      required this.atmosphere,
      required this.djAndCaller,
      required this.id,
      required this.songs,
      required this.art});

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
    int minUnique;
    //adverts and ids are played after each song, the worst case is the same ad with the longest duration playing each time
    numberOfSongs = songs.length;
    maxDuration += id.maxDuration(numberOfSongs);
    maxDuration += AudioData.longAdverts.maxDuration(numberOfSongs);
    maxDuration += AudioData.shortAdverts.maxDuration(numberOfSongs);
    //two atmoshpere info are played
    maxDuration += atmosphere.maxDuration;
    //play max possible number of dj and caller without repeating
    minUnique = min<int>(djAndCaller.length, numberOfSongs);
    maxDuration += djAndCaller.maxDuration(minUnique);

    return maxDuration;
  }

  int _sumDurationOfSongs() {
    int duration = 0;
    for (var song in songs) duration += song.duration;
    return duration;
  }

  factory RadioStation.fromJson(json) {
    var atmosphere = Atmosphere.fromJson(json['atmosphere']);
    var caller =
        (json['caller'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var id = (json['id'] as List).map((e) => AudioFile.fromJson(e)).toList();
    var dj = (json['dj'] as List).map((e) => AudioFile.fromJson(e)).toList();
    dj.addAll(caller);
    var songs = (json['songs'] as List).map((e) => Song.fromJson(e)).toList();
    return RadioStation(
        art: PathService.appendAssetFolder(json['art']),
        name: json['name'],
        atmosphere: atmosphere,
        djAndCaller: dj,
        id: id,
        songs: songs);
  }

  MediaItem getMediaItem() {
    return MediaItem(id: name, title: name);
  }

  @override
  String toString() {
    return "RadioStation $name, songs(${songs.length}), djAndCaller(${djAndCaller.length}), id(${id.length}))";
  }
}
