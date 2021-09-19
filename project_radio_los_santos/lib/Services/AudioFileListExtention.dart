import 'package:project_radio_los_santos/Models/AudioFile.dart';

extension AudioFileListExtention on List<AudioFile> {
  int sumDuration() {
    int duration = 0;
    for (var item in this) duration += item.duration;
    return duration;
  }

  int maxDuration(int number) {
    List<AudioFile> sortedList = List<AudioFile>.from(this);
    sortedList.sort((a, b) => b.duration - a.duration);
    int duration = 0;
    int sumOfDurations = sumDuration();
    while (number >= length) {
      duration += sumOfDurations;
      number -= length;
    }
    for (var i = 0; i < number; i++) {
      duration += sortedList[i].duration;
    }
    return duration;
  }

  AudioFile longestFile() {
    AudioFile longest = this[0];
    for (var i = 1; i < length; i++) {
      var currentFile = this[i];
      if (longest.duration < currentFile.duration) longest = currentFile;
    }
    return longest;
  }

  AudioFile shortestFile() {
    AudioFile shortest = this[0];
    for (var i = 1; i < length; i++) {
      var currentFile = this[i];
      if (shortest.duration > currentFile.duration) shortest = currentFile;
    }
    return shortest;
  }
}
