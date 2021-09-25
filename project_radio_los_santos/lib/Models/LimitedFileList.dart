import 'dart:math';

import 'package:project_radio_los_santos/Models/IAudioFile.dart';
import 'package:project_radio_los_santos/Services/AudioFileListExtention.dart';

class LimitedFileList {
  final Random randomGenerator;
  final List<IAudioFile> list;
  final List<bool> isUsed;
  int nbUsed = 0;
  int effectiveLength;
  double emptyProbablity;
  bool infinit;
  bool debug;

  LimitedFileList({
    this.emptyProbablity = 0,
    required this.list,
    int? effectiveLength,
    this.infinit = false,
    this.debug = false,
    required this.randomGenerator,
  })  : isUsed = List<bool>.generate(list.length, (_) => false),
        effectiveLength = effectiveLength ?? list.length {
    if (debug) print("constructor ${this.effectiveLength}");
  }

  int shortestDuration() => list.shortestDuration();

  int get listLength => list.length;

  bool get isEmpty =>
      list.isEmpty ||
      effectiveLength == 0 ||
      //nbUsed == list.length ||
      emptyProbablity == 1;

  List<IAudioFile> _getEffectiveList({bool Function(IAudioFile)? filter}) {
    if (debug) {
      int nbTrue = 0;
      int nbFalse = 0;
      for (var item in isUsed) {
        if (item)
          nbTrue++;
        else
          nbFalse++;
      }
      print("nbTrue = $nbTrue, nbFalse = $nbFalse, nbUsed = $nbUsed");
    }
    List<IAudioFile> result = [];
    var localFilter = filter;
    if (localFilter == null) {
      for (var i = 0; i < list.length; i++) if (!isUsed[i]) result.add(list[i]);
    } else {
      for (var i = 0; i < list.length; i++)
        if (!isUsed[i] && localFilter(list[i])) result.add(list[i]);
    }
    nbUsed++;
    return result;
  }

  void _resetIsUsed() {
    nbUsed = 0;
    for (var i = 0; i < isUsed.length; i++) {
      isUsed[i] = false;
    }
  }

  void reset({double? emptyProbablity, int? effectiveLength, bool? infinit}) {
    _resetIsUsed();
    if (emptyProbablity != null) this.emptyProbablity = emptyProbablity;
    if (effectiveLength != null) this.effectiveLength = effectiveLength;
    if (infinit != null) this.infinit = infinit;
    if (debug)
      print(
          "reset: emptyProb = $emptyProbablity, effectiveLength = $effectiveLength, infiti = $infinit");
  }

  IAudioFile? getAudioFile({bool Function(IAudioFile file)? filter}) {
    if (debug) print("effective length = ${effectiveLength}");
    if (isEmpty || emptyProbablity == 1) return null;
    double randDouble = randomGenerator.nextDouble();
    if (randDouble < emptyProbablity) return null;
    if (nbUsed == isUsed.length) _resetIsUsed();
    var effectiveList = _getEffectiveList(filter: filter);
    if (effectiveList.isEmpty) return null;
    var randomIndex = randomGenerator.nextInt(effectiveList.length);
    isUsed[list.indexOf(effectiveList[randomIndex])] = true;
    if (!infinit) effectiveLength--;
    return effectiveList[randomIndex];
  }
}
