import 'package:flutter/material.dart';

extension TimeOfDayCalc on TimeOfDay {
  bool isBefore(TimeOfDay other) {
    return minutesSinceMidnight < other.minutesSinceMidnight;
  }

  int get minutesSinceMidnight => hour * 60 + minute;

  String getFormatted() {
    return "${hour}h " + (minute < 10 ? "0" : "") + "${minute}m";
  }
}

TimeOfDay fromDuration(Duration duration) {
  int inMinutes = duration.inMinutes;
  return TimeOfDay(hour: (inMinutes / 60).floor(), minute: inMinutes % 60);
}
