import 'package:project_radio_los_santos/Models/AudioFile.dart';

extension AudioFileListExtention on List<AudioFile> {
  int sumDuration() {
    int duration = 0;
    for (var item in this) duration += item.duration;
    return duration;
  }

  int maxDuration(int? number) {
    int neededNumber = number ?? this.length;
    List<AudioFile> sortedList = List<AudioFile>.from(this);
    sortedList.sort((a, b) => a.duration - b.duration);
    int duration = 0;
    while (neededNumber >= this.length) {
      duration += this.sumDuration();
      neededNumber -= this.length;
    }
    for (var i = 0; i < neededNumber; i++) {
      duration += sortedList[i].duration;
    }
    return duration;
  }
}
