import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension TimeOfDayCalc on TimeOfDay {
  bool isBefore(TimeOfDay other) {
    return minutesSinceMidnight < other.minutesSinceMidnight;
  }

  int get minutesSinceMidnight => hour * 60 + minute;

  String getFormatted() {
    return "${hour}h " + (minute < 10 ? "0" : "") + "${minute}m";
  }
}

DateFormat monthYearFormatter = DateFormat.yMMMM();

TimeOfDay fromDuration(Duration duration) {
  int inMinutes = duration.inMinutes;
  return TimeOfDay(hour: (inMinutes / 60).floor(), minute: inMinutes % 60);
}

class HoursMinutes {
  bool negative = false;
  int hours;
  int minutes;

  bool get positive => !negative;

  HoursMinutes(this.hours, this.minutes, {this.negative = false})
      : assert(minutes < 60);

  HoursMinutes.zero()
      : hours = 0,
        minutes = 0;

  HoursMinutes.fromDuration(Duration duration)
      : hours = (duration.inMinutes / 60).floor(),
        minutes = duration.inMinutes % 60;

  HoursMinutes.fromMap(Map<String, dynamic> data)
      : hours = data["hours"],
        minutes = data["minutes"],
        negative = data["negative"] ?? false;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {};
    result["hours"] = hours;
    result["minutes"] = minutes;
    if (negative) {
      result["negative"] = negative;
    }
    return result;
  }

  double get durationDecimal =>
      (negative ? -1 : 1) * (hours + (minutes / 60.0));

  void add(HoursMinutes other) {
    HoursMinutes hoursMinutes = _add(negative, hours, minutes, other);
    hours = hoursMinutes.hours;
    minutes = hoursMinutes.minutes;
    negative = hoursMinutes.negative;
  }

  static HoursMinutes _add(
      bool newNegative, int newHours, int newMins, HoursMinutes other) {
    if (other.negative == newNegative) {
      newHours += other.hours;
      newMins += other.minutes;
      if (newMins >= 60) {
        newMins = newMins - 60;
        newHours++;
      }
    } else {
      newHours -= other.hours;
      newMins -= other.minutes;
      if (newMins < 0) {
        newMins = 60 + newMins;
        newNegative = newHours <= 0;
      } else {
        newNegative = newHours < 0;
      }
      newHours = newHours.abs();
    }

    return HoursMinutes(newHours, newMins, negative: newNegative);
  }

  HoursMinutes operator +(HoursMinutes other) {
    return _add(negative, hours, minutes, other);
  }

  HoursMinutes operator -(HoursMinutes other) {
    bool newNegative = negative;
    int newMins = minutes;
    int newHours = hours;
    if (other.negative == negative) {
      newHours -= other.hours;
      newMins -= other.minutes;
      if (newMins < 0) {
        newMins = 60 + newMins;
        newNegative = newHours <= 0;
      } else {
        newNegative = newHours < 0;
      }
      newHours = newHours.abs();
    } else {
      newHours += other.hours;
      newMins += other.minutes;
      if (newMins >= 60) {
        newMins = newMins - 60;
        newHours++;
      }
    }

    return HoursMinutes(newHours, newMins, negative: newNegative);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HoursMinutes &&
        other.negative == negative &&
        other.hours == hours &&
        other.minutes == minutes;
  }

  @override
  String toString() {
    return (negative ? "-" : "") +
        hours.toString() +
        "h" +
        (minutes > 0 ? (" " + minutes.toString() + "m") : "");
  }

  String toCsv() {
    return toString();
  }

  @override
  int get hashCode => negative.hashCode ^ hours.hashCode ^ minutes.hashCode;
}
