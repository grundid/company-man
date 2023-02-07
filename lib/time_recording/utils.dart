import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

import 'package:smallbusiness/reusable/model_utils.dart';
import 'package:smallbusiness/time_recording/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

int calculateWage(HoursMinutes duration, WageHolder wage) {
  return (duration.durationDecimal * wage.wageInCent).round();
}

DateTime nextDay(DateTime date) {
  DateTime lastHourOfDay = DateTime(date.year, date.month, date.day, 23);
  return lastHourOfDay.add(Duration(hours: 1));
}

DateTime createFrom(DateTime fromDate, TimeOfDay from) {
  DateTime result = DateTime(
      fromDate.year, fromDate.month, fromDate.day, from.hour, from.minute);
  if (result.isBefore(fromDate)) {
    result = nextDay(result);
    result =
        DateTime(result.year, result.month, result.day, from.hour, from.minute);
  }
  return result;
}

DateTime? createTo(DateTime fromDate, TimeOfDay from, TimeOfDay? to) {
  if (to != null) {
    DateTime myTo = DateTime(fromDate.year, fromDate.month, fromDate.day);
    if (to.isBefore(from)) {
      myTo = nextDay(myTo);
    }
    return DateTime(myTo.year, myTo.month, myTo.day, to.hour, to.minute);
  } else {
    return null;
  }
}

TimeOfDay createFromNow({int minuteStep = 1}) {
  DateTime fromDate = DateTime.now();
  int hour = fromDate.hour;
  int minute = (fromDate.minute / minuteStep).floor() * minuteStep;
  return TimeOfDay(hour: hour, minute: minute);
}

class WorkTimeState extends TimeRecordingDuration {
  @override
  final DateTime from;
  @override
  final DateTime? to;
  @override
  final List<Pause> pauses;
  final DateTime now;

  Duration? get workDuration => to?.difference(from);

  WorkTimeState(
      {required this.from, this.to, required this.pauses, DateTime? now})
      : now = now ?? DateTime.now();

  factory WorkTimeState.fromFormBuilderState(FormBuilderState currentState) {
    // TODO put field values into a map and call fromFormValues
    DateTime fromDate = currentState.fields["fromDate"]!.value;
    TimeOfDay fromTime = currentState.fields["fromTime"]!.value;
    TimeOfDay? toTime = currentState.fields["toTime"]!.value;
    List<Pause> pauses = currentState.fields["pauses"]?.value ?? [];

    DateTime from = createFrom(fromDate, fromTime);
    DateTime? to = createTo(fromDate, fromTime, toTime);
    return WorkTimeState(from: from, to: to, pauses: pauses);
  }

  factory WorkTimeState.fromFormValues(Map<String, dynamic> formValues) {
    DateTime fromDate = formValues["fromDate"];
    TimeOfDay fromTime = formValues["fromTime"];
    TimeOfDay? toTime = formValues["toTime"];
    List<Pause> pauses = formValues["pauses"] ?? [];

    DateTime from = createFrom(fromDate, fromTime);
    DateTime? to = createTo(fromDate, fromTime, toTime);
    return WorkTimeState(from: from, to: to, pauses: pauses);
  }

  bool get finishable => to != null;

  String? validateTo([BuildContext? context]) {
    if (to != null) {
      if (to!.isAfter(now.add(Duration(hours: 1)))) {
        return context != null
            ? AppLocalizations.of(context)!
                .dieEndeZeitDarfNichtMehrAls1hInDerZukunftLiegen
            : "Die Ende-Zeit darf nicht mehr als 1h in der Zukunft liegen.";
      } else if (workDuration!.inMinutes < 1) {
        return context != null
            ? AppLocalizations.of(context)!
                .dieArbeitszeitDarfNichtWenigerAls1MinuteBetragen
            : "Die Arbeitszeit darf nicht weniger als 1 Minute betragen.";
      }
    }
    return null;
  }

  String? validatePauses([BuildContext? context]) {
    for (Pause pause in pauses) {
      if (pause.from.isBefore(from) || (to != null && pause.to.isAfter(to!))) {
        return context != null
            ? AppLocalizations.of(context)!
                .diePauseDarfNichtAusserhalbDerArbeitszeitLiegen
            : "Die Pause darf nicht außerhalb der Arbeitszeit liegen.";
      }
    }

    if (presenceDuration != null) {
      int presenceInMinutes = presenceDuration!.inMinutes;
      int pauseInMinutes = pauseDuration.inMinutes;

      if (presenceInMinutes > 9 * 60 && pauseInMinutes < 45) {
        return context != null
            ? AppLocalizations.of(context)!
                .nach9hArbeitMuessenMindestens45MinutenPauseerfasstWerden
            : "Nach 9h Arbeit müssen mindestens 45 Minuten Pause erfasst werden.";
      }
      if (presenceInMinutes > 6 * 60 && pauseInMinutes < 30) {
        return context != null
            ? AppLocalizations.of(context)!
                .nach6hArbeitMuessenMindestens30MinutenPauseerfasstWerden
            : "Nach 6h Arbeit müssen mindestens 30 Minuten Pause erfasst werden.";
      }
    }

    return null;
  }

  @override
  String toString() {
    return 'WorkTimeState(from: $from, to: $to, pauses: $pauses)';
  }
}

bool isOverlapping(TimeRecordingDuration tr1, TimeRecordingDuration tr2) {
  // tr2 starts with tr1
  if (tr1.from.isAtSameMomentAs(tr2.from)) {
    return true;
  }
  if (tr1.to != null) {
    // tr2 from is within tr1
    if (tr1.from.isBefore(tr2.from) && tr1.to!.isAfter(tr2.from)) {
      return true;
    }

    if (tr2.to != null) {
      // tr2 ends with tr1
      if (tr1.to!.isAtSameMomentAs(tr2.to!)) {
        return true;
      }
      // tr2 to is within tr1
      if (tr1.from.isBefore(tr2.to!) && tr1.to!.isAfter(tr2.to!)) {
        return true;
      }
    }
  }
  if (tr2.to != null) {
    // tr1 from is within tr2
    if (tr2.from.isBefore(tr1.from) && tr2.to!.isAfter(tr1.from)) {
      return true;
    }
  }

  return false;
}

bool isNotEmpty(String? value) {
  return true == value?.trim().isNotEmpty;
}
