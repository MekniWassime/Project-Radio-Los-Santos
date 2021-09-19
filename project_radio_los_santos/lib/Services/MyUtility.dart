class MyUtility {
  MyUtility._();

  static int? getMax(List<int> list) {
    if (list.isEmpty) return null;
    int max = list[0];
    for (var i = 1; i < list.length; i++) {
      if (list[i] > max) max = list[i];
    }
    return max;
  }
}
