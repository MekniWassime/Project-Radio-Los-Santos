import 'package:project_radio_los_santos/Models/IAudioFile.dart';

extension AudioFileListExtention on List<IAudioFile> {
  int get totalDuration {
    int duration = 0;
    for (var item in this) duration += item.duration;
    return duration;
  }

  /// copy the first length elements including Empty items nbEmpty
  List<IAudioFile> copy() {
    return List<IAudioFile>.from(this);
  }

  bool addNotNull(IAudioFile? element) {
    if (element == null) return false;
    add(element);
    return true;
  }

  int maxDurationForNumberOfElements(int number) {
    if (isEmpty) return 0;
    List<IAudioFile> sortedList = List<IAudioFile>.from(this);
    sortedList.sort((a, b) => b.duration - a.duration);
    int duration = 0;
    int sumOfDurations = totalDuration;
    while (number >= length) {
      duration += sumOfDurations;
      number -= length;
    }
    for (var i = 0; i < number; i++) {
      duration += sortedList[i].duration;
    }
    return duration;
  }

  int longestDuration() {
    if (isEmpty) return 0;
    int longest = this[0].duration;
    for (var i = 1; i < length; i++) {
      var currentFile = this[i];
      if (longest < currentFile.duration) longest = currentFile.duration;
    }
    return longest;
  }

  int shortestDuration() {
    if (isEmpty) return 0;
    int shortest = this[0].duration;
    for (var i = 1; i < length; i++) {
      var currentFile = this[i];
      if (shortest > currentFile.duration) shortest = currentFile.duration;
    }
    return shortest;
  }
}
